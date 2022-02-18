$(() => {
  const currentLocale = $("html").attr("lang");
  const $search = $("#data_picker-autocomplete");
  const $results = $("#tags-results");
  const $template = $(".decidim-template", $results);
  const $form = $search.parents("form");
  let currentSearch = "";
  let selectedTerms = [];
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
      selectedTerms = selectedTerms.filter((item) => item !== title);
    });
    selectedTerms.push(title);
  };
  let xhr = null;

  // Prevent accidental submit on the autocomplete field
  $form.on("submit", (ev) => ev.preventDefault());

  // jquery.autocomplete is calling this method which is apparently removed from
  // newer jQuery versions.
  $.isObject = $.isPlainObject; // eslint-disable-line id-length

  const customizeAutocomplete = (ac) => {
    const $ac = $(`#${ac.mainContainerId}`);
    const $acWrap = $("<div />");
    $ac.css({ top: "", left: "", position: "relative" });
    $acWrap.css({ position: "relative" });
    $acWrap.append($ac);

    $ac.find("input")

    const removeNoResultSuggestion = () => {
      const $noResultsSuggestion = $ac.find("#no-result-suggest")
      if ($noResultsSuggestion) {
        $noResultsSuggestion.remove();
      }
    }

    $search.on("keyup", function() {
      currentSearch = $search.val();

      if ($search.val().length === 0) {
        removeNoResultSuggestion();
      }
    });

    // Move the element to correct position in the DOM to control its alignment
    // better.
    $search.after($acWrap);

    // Do not set the top and left CSS attributes on the element
    ac.fixPosition = () => {};

    // Hack getSuggetsions
    ac.getSuggestions = (q) => {
      var self = ac
      var cached = self.isLocal ? self.getSuggestionsLocal(q) : ac.cachedResponse[q]
      if (cached && ($.isArray(cached.suggestions) || $.isObject(cached.suggestions))) {
        self.suggestions = cached.suggestions
        self.data = cached.data
        self.suggest()
      } else if (!ac.isBadQuery(q)) {
        xhr = $.post(
          "/api",
          {query: `{tags(name:"${q}", locale:"${currentLocale}") {id, name { translations {text, locale} }}}`}
        ).then((apiResponse) => {
          const data = apiResponse.data.tags || {};
          const results = data.map((item) => {
            let name = item.name.translations.find((tr) => tr.locale === currentLocale);
            if (!name) {
              name = item.name.translations[0];
            }
            return [item.id, name.text];
          })

          if (results.length > 0) {
            removeNoResultSuggestion();

            let suggestions = [];
            let data = []
            results.forEach((result) => {
              data.push(
                {
                  value: result[1],
                  data: result[0]
                });
              suggestions.push(result[1]);
            });
            ac.processResponse(JSON.stringify({
              query: q,
              suggestions: suggestions,
              data: data
            }));
          } else if (q.length > 2) {
            const val = $search.data("no-results-text");
            const url = $search.data("no-results-url").replace("{{term}}", encodeURIComponent(q));
            $ac.append(`<div id="no-result-suggest"><a href="${url}">${val.replace("{{term}}", q)}</a></div>`);
          }
        });
      }
    };

    // Hack the suggest method to exclude values that are already selected.
    ac.origSuggest = ac.suggest;
    ac.suggest = () => {
      // Filter out the selected items from the list
      ac.suggestions = ac.suggestions.filter((val) => !selectedTerms.includes(val));
      ac.data = ac.data.filter((val) => !selectedTerms.includes(val.value));

      return ac.origSuggest();
    };

    // Customize the onKeyPress to allow spaces because we do not want
    // selection to happen on space press.
    //
    // Original code at: https://git.io/JzjAM
    ac.onKeyPress = (ev) => {
      if (ac.disabled || !ac.enabled) {
        return;
      }

      switch (ev.keyCode) {
      case 27:
        // ESC
        ac.el.val(ac.currentValue);
        ac.hide();
        break;
      case 9:
      case 13:
        // TAB or RETURN
        if (ac.suggestions.length === 1) {
          ac.select(0)
        } else if (ac.selectedIndex === -1) {
          ac.hide();
          return;
        } else {
          ac.select(ac.selectedIndex);
        }
        if (ev.keyCode === 9) {
          return;
        }
        break;
      case 38:
        // UP
        ac.moveUp();
        break
      case 40:
        // DOWN
        ac.moveDown();
        break
      // DISABLED:
      // case 32:
      //   // SPACE
      //   if (ac.selectedIndex === -1) {
      //     break;
      //   }
      //   ac.select(ac.selectedIndex);
      //   break;
      default:
        return;
      }
      ev.stopImmediatePropagation();
      ev.preventDefault();
    }

    return ac;
  };

  // Customized methods for the autocomplete to add our hacks
  $.fn.tcAutocomplete = function(options) {
    $(this).each((_i, el) => {
      const $el = $(el);
      const ac = customizeAutocomplete($el.autocomplete(options));
      $el.data("autocomplete", ac);
    })
  };

  $search.tcAutocomplete({
    width: "100%",
    minChars: 2,
    noCache: true,
    // serviceUrl: $form.attr("action"),
    // delimiter: "||",
    deferRequestBy: 500,
    // Custom format result because of some weird bugs in the old version of the
    // jquery.autocomplete library.
    formatResult: (term, itemData) => {
      const sanitizedSearch = term.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&");
      const re = new RegExp(`(${sanitizedSearch})`, "gi");

      const value = `${itemData.value}`;
      return value.replace(re, "<strong>$1</strong>");
    },
    onSelect: function(suggestion, itemData) {
      addRowItem(itemData.data, itemData.value);
      $search.val(currentSearch);
    }
  });

  const resultsArray = $results.data("results");
  if (Array.isArray(resultsArray)) {
    resultsArray.forEach((value) => {
      addRowItem(value[0], value[1]);
    });
  }
});
