import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  const tagContainers = document.querySelectorAll("#tags_list");

  tagContainers.forEach((container) => {
    const { tmName, tmItems, tmNoResults } = container.dataset;

    const config = {
      plugins: ["remove_button"],
      allowEmptyOption: true,
      items: JSON.parse(tmItems),
      render: {
        item: (data, escape) => `<div>${escape(data.text)}<input type="hidden" name="${tmName}" value="${data.value}" /></div>`,
        // eslint-disable-next-line camelcase
        ...(tmNoResults && { no_results: () => `<div class="no-results">${tmNoResults}</div>` })
      }
    };

    const tom = new TomSelect(container, config)

    const togglePlaceholder = () => {
      const currentColumn = container.closest(".row.column");

      const tagsInput = currentColumn.querySelector(".ts-control #tags_list-ts-control")

      if (!tagsInput.classList.contains("placeholder-transparent") && tom.items.length > 0) {
        console.log("testi")
        tagsInput.classList.add("placeholder-transparent");
      } else if (tagsInput.classList.contains("placeholder-transparent") && tom.items.length === 0) {
        tagsInput.classList.remove("placeholder-transparent");
      }
    }

    togglePlaceholder();
    tom.on("item_add", togglePlaceholder);
    tom.on("item_remove", togglePlaceholder);

    return tom
  })
});
