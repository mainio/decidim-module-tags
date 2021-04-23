((exports) => {
  const $ = exports.$; // eslint-disable-line id-length
  const Tribute = exports.Tribute;

  $(() => {
    const currentLocale = $("html").attr("lang");

    $(".js-tags-input").each((_i, tagsEl) => {
      const $wrapper = $(tagsEl);
      const $input = $(".input-tags", $wrapper);
      const inputName = $wrapper.data("input-name");

      let $autocomplete = $(".autocomplete", $wrapper);
      if ($autocomplete.length < 1) {
        $autocomplete = $('<div class="autocomplete"></div>');
        $wrapper.append($autocomplete);
      }

      const i18n = {
        remove: $wrapper.data("remove-text") || "Remove",
        loading: $wrapper.data("loading-text") || "Loading...",
        noResults: $wrapper.data("no-results-text") || "No tags available."
      };

      const cleanInput = () => {
        // Remove the extra text
        let nonTextNodeSeen = false;
        let previousNodeNbsp = false;
        $input.contents().each((_j, node) => {
          if (node.nodeName !== "#text") {
            previousNodeNbsp = false;
            nonTextNodeSeen = true;
            return;
          } else if (node.nodeValue === "\xa0") {
            if (!previousNodeNbsp) {
              previousNodeNbsp = true;
              if (nonTextNodeSeen) {
                return;
              }
            }
          } else {
            previousNodeNbsp = false;
          }

          node.remove();
        });
        if (!$input.html().trim().match(/&nbsp;$/)) {
          $input.append("&nbsp;");
        }
      };

      const updateValues = () => {
        const $tags = $(".label", $input);
        $("input", $wrapper).remove();

        if ($tags.length < 1) {
          $input.addClass("empty");
          return;
        }
        $input.removeClass("empty");

        $(".label", $input).each((_j, el) => {
          const $tag = $(el);
          const name = $(".tag-name", $tag).text();
          $wrapper.append(
            `<input type="hidden" name="${inputName}" value="${$tag.data("tag-id")}" data-tag-name="${name}">`
          );

          $tag.off("click.decidim-tags").on("click.decidim-tags", () => {
            $tag.remove();
            updateValues();
          });
        });

        // Make sure the cursor is not on top of the label
        $(".label:last", $input).append(" ");
      };

      const createTag = (id, name) => {
        // The spacer element keeps the cursor in the correct position after the
        // tag is inserted.
        return (
          `<span class="label primary" data-tag-id="${id}" contenteditable="false" tabindex="0">
            <span class="tag-name">${name}</span>
            <span class="tag-remove" aria-label="${i18n.remove}: ${name}"><span aria-hidden="true">&times;</span></span>
          </span>`
        );
      };

      const getCurrentValues = () => {
        return $("input", $wrapper).toArray().map((el) => {
          const $tagInput = $(el);
          return { key: $tagInput.data("tag-name"), value: $tagInput.val() };
        });
      };

      const filterCurrentValues = (values) => {
        const current = getCurrentValues().map((val) => val.value);
        return values.filter((val) => !current.includes(val.value));
      };

      $input.attr("contenteditable", true);

      let xhr = null;
      const tribute = new Tribute({
        autocompleteMode: true,
        // autocompleteSeparator: / \+ /, // See below, requires Tribute update
        allowSpaces: true,
        positionMenu: false,
        replaceTextSuffix: "&nbsp;",
        menuContainer: $autocomplete.get(0),
        menuShowMinLength: 2,
        noMatchTemplate: `<ul class="tags-no-matches"><li>${i18n.noResults}</li></ul>`,
        loadingItemTemplate: `<ul class="tags-loading"><li>${i18n.loading}</li></ul>`,
        selectTemplate: (item) => {
          if (!item || !item.original) {
            return "";
          }

          return createTag(item.original.value, item.original.key);
        },
        values: (text, callback) => {
          try {
            xhr.abort();
            xhr = null;
          } catch (exception) { xhr = null; }

          xhr = $.post(
            "/api",
            {query: `{tags(name:"${text}", locale:"${currentLocale}") {id, name { translations {text, locale} }}}`}
          ).then((response) => {
            const data = response.data.tags || {};
            callback(
              filterCurrentValues(
                data.map((item) => {
                  let name = item.name.translations.find((tr) => tr.locale === currentLocale);
                  if (!name) {
                    name = item.name.translations[0];
                  }
                  return { key: name.text, value: item.id };
                })
              )
            );
          }).fail(() => {
            callback([]);
          });
        }
      });

      // Port https://github.com/zurb/tribute/pull/406
      // This changes the autocomplete separator from space to " + " so that
      // we can do searches such as "tag name" including a space. Otherwise
      // this would do two separate searches for "tag" and "name".
      tribute.range.getLastWordInText = (text) => {
        const final = text.replace(/\u00A0/g, " ");
        const wordsArray = final.split(/ \+ /);
        const worldsCount = wordsArray.length - 1;

        return wordsArray[worldsCount].trim();
      };

      tribute.attach($input[0]);

      // Add the initial tags to the view
      $("input", $wrapper).each((_j, el) => {
        const $tagInput = $(el);
        $input.append(createTag($tagInput.val(), $tagInput.data("tag-name")));
      });

      let updateTimeout = null;
      $input.on("keydown.decidim-tags", (ev) => {
        if (ev.keyCode === 8) {
          // backspace
          // Use a timeout because the label still exists in the element during
          // keydown.
          clearTimeout(updateTimeout);
          updateTimeout = setTimeout(() => {
            updateValues();
          }, 5);
        } else if (ev.keyCode === 13) {
          // enter
          return false;
        }

        return true;
      }).on("paste.decidim-tags", (ev) => {
        ev.preventDefault();
      }).on("blur.decidim-tags", () => {
        updateValues();
        cleanInput();
      });

      $input.on("tribute-replaced", () => {
        updateValues();
      });

      updateValues();
      cleanInput();
    });
  });
})(window);
