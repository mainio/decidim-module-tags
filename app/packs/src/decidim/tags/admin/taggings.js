import AutoComplete from "src/decidim/autocomplete";
$(() => {
  const currentLocale = $("html").attr("lang");
  const searchInput = document.getElementById("data_picker-autocomplete");
  const results = document.getElementById("tags-results");
  const template = results.querySelector(".decidim-template");
  const form = $("#data_picker-autocomplete").parents("form");

  let currentSearch = "";
  let selectedTerms = [];
  let xhr = null;

  searchInput.addEventListener("keyup", () => {
    currentSearch = searchInput.value;
  });

  // Prevent accidental submit on the autocomplete field
  form.on("submit", (ev) => ev.preventDefault());

  const noTagContent = (query) => {
    const el = document.querySelector(".autoComplete_wrapper");
    const val = $("#data_picker-autocomplete").data("no-results-text");
    const url = $("#data_picker-autocomplete").data("no-results-url").replace("{{term}}", encodeURIComponent(query));

    if (el.querySelector(".no-content")) {
      el.querySelector(".no-content").classList.remove("hide")
    } else {
      let newDiv = el.appendChild(document.createElement("div"))
      newDiv.classList.add("no-content")
    }
    const noContent = el.querySelector(".no-content")
    noContent.innerHTML = `<a href="${url}">${val.replace("{{term}}", query)}</a>`;
  }

  const dataSource = (query, callback) => {
    try {
      xhr.abort();
      xhr = null;
    } catch (exception) { xhr = null; }

    xhr = $.post(
      "/api",
      {query: `{tags(name:"${query}", locale:"${currentLocale}") {id, name { translations {text, locale} }}}`}
    ).then((response) => {
      if (response.data.tags.length === 0) {
        noTagContent(currentSearch)
      }
      const tags = response.data.tags.map((tag) => {
        const localName = tag.name.translations.find((tr) => tr.locale === currentLocale);
        return { id: tag.id, name: localName.text };
      })

      callback(tags);
    });
  };

  // Just to avoid the "no-new" ESLint issue, wrap this in a function
  const initiate = () => {
    return new AutoComplete(searchInput, {
      name: searchInput.getAttribute("name"),
      placeholder: searchInput.getAttribute("placeholder"),
      selected: "",
      searchPrompt: true,
      searchPromptText: "placeholder",
      threshold: 2,
      dataMatchKeys: ["name"],
      modifyResult: (item, valueItem) => {
        const sanitizedSearch = currentSearch.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&");
        const re = new RegExp(`(${sanitizedSearch})`, "gi");
        const replacedText = item.textContent.replace(re, '<strong class="search-highlight">$1</strong>');
        item.innerHTML = replacedText;
        item.dataset.value = valueItem.name;
      },
      dataSource
    });
  };

  // Method for hiding the currently selected items
  const hideSelectedItems = () => {
    const resultsList = searchInput.nextSibling;
    for (const resultItem of resultsList.querySelectorAll("li")) {
      if (selectedTerms.indexOf(resultItem.dataset.value) < 0) {
        resultItem.classList.remove("hide");
      } else {
        resultItem.classList.add("hide");
      }
    }
  };
  initiate();

  const addRowItem = (id, name) => {
    const newRow = template.content.cloneNode(true).querySelector("tr");
    newRow.innerHTML = newRow.innerHTML.replace(new RegExp("{{tag_id}}", "g"), id);
    newRow.innerHTML = newRow.innerHTML.replace(new RegExp("{{tag_name}}", "g"), name);
    newRow.dataset.tagId = newRow.dataset.tagId.replace(new RegExp("{{tag_id}}", "g"), id)

    const targetTable = results.querySelector("table tbody");
    targetTable.appendChild(newRow);
    results.classList.remove("hide");


    // Add it to the selected elements and hide the selected item
    selectedTerms.push(name);
    hideSelectedItems();


    // Listen to the click event on the remove button
    newRow.querySelector(".action-icon--remove").addEventListener("click", (removeEv) => {
      removeEv.preventDefault();
      newRow.parentNode.removeChild(newRow);
      selectedTerms = selectedTerms.filter((item) => item !== name);
      hideSelectedItems();

      if (targetTable.querySelectorAll("tr").length < 1) {
        results.classList.add("hide");
      }
    });
  }

  // Currently not possible in Decidim to get notified when the list is
  // modified, so hack it with a MutationObserver.
  // Create an observer instance linked to the callback function
  const observer = new MutationObserver(() => {
    hideSelectedItems();
  });
  observer.observe(searchInput.nextSibling, { childList: true });

  // Hide the already selected items when the input is opened
  // Handle the selection of an item
  searchInput.addEventListener("selection", (ev) => {
    const selection = ev.detail.selection;
    const selectedItem = selection.value;
    addRowItem(selectedItem.id, selectedItem.name);
  });

  const resultsArray = JSON.parse(results.dataset.results)
  if (Array.isArray(resultsArray)) {
    resultsArray.forEach((value) => {
      addRowItem(value[0], value[1]);
    });
  }
});
