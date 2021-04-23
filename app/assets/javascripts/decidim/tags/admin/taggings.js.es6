((exports) => {
  const $ = exports.$; // eslint-disable-line id-length

  $(() => {
    const currentLocale = $("html").attr("lang");
    const $search = $("#data_picker-autocomplete");
    const $results = $("#tags-results");
    const $template = $(".decidim-template", $results);
    const addRowItem = (id, title) => {
      let template = $template.html();
      template = template.replace(new RegExp("{{tag_id}}", "g"), id);
      template = template.replace(new RegExp("{{tag_name}}", "g"), title);
      const $newRow = $(template);
      $("table tbody", $results).append($newRow);
      $results.removeClass("hide");

      // Listen to the click event on the remove button
      $(".remove-tagging", $newRow).on("click", (ev) => {
        ev.preventDefault();
        $newRow.remove();

        if ($("table tbody tr", $results).length < 1) {
          $results.addClass("hide");
        }
      });
    };
    const filterCurrentValues = (values) => {
      const current = $("input[name='tags[]']", $results).toArray().map((el) => {
        return $(el).val();
      });
      return values.filter((val) => !current.includes(val[0]));
    };
    let xhr = null;
    let currentSearch = "";

    $search.on("keyup", () => {
      currentSearch = $search.val();
    });

    $search.autoComplete({
      minChars: 2,
      cache: 0,
      source: (term, response) => {
        try {
          xhr.abort();
        } catch (exception) { xhr = null; }

        xhr = $.post(
          "/api",
          {query: `{tags(name:"${term}", locale:"${currentLocale}") {id, name { translations {text, locale} }}}`}
        ).then((apiResponse) => {
          const data = apiResponse.data.tags || {};
          const results = filterCurrentValues(
            data.map((item) => {
              let name = item.name.translations.find((tr) => tr.locale === currentLocale);
              if (!name) {
                name = item.name.translations[0];
              }
              return [item.id, name.text];
            })
          )

          if (results.length > 0) {
            response(results);
          } else {
            response([
              [null, $search.data("no-results-text"), term]
            ]);
          }
        }).fail(() => {
          response([
            [null, $search.data("no-results-text"), term]
          ]);
        });
      },
      renderItem: (item, search) => {
        const sanitizedSearch = search.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&");
        const re = new RegExp(`(${sanitizedSearch.split(" ").join("|")})`, "gi");
        const modelId = item[0];
        const title = item[1];
        const val = `${title}`;

        if (modelId === null) {
          // Empty result
          const term = item[2];
          const url = $search.data("no-results-url").replace("{{term}}", encodeURIComponent(term));
          return `<div><a href="${url}">${val.replace("{{term}}", term)}</a></div>`;
        }
        return `<div class="autocomplete-suggestion" data-model-id="${modelId}" data-val="${title}">${val.replace(re, "<b>$1</b>")}</div>`;
      },
      onSelect: (_event, _term, item) => {
        const $suggestions = $search.data("sc");
        const modelId = item.data("modelId");
        const title = item.data("val");

        addRowItem(modelId, title);

        $search.val(currentSearch);
        setTimeout(() => {
          $(`[data-model-id="${modelId}"]`, $suggestions).remove();
          $suggestions.show();
        }, 20);
      }
    });

    const resultsArray = $results.data("results");
    if (Array.isArray(resultsArray)) {
      resultsArray.forEach((value) => {
        addRowItem(value[0], value[1]);
      });
    }
  });
})(window);
