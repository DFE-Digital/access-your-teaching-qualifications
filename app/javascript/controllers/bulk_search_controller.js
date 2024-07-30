export default class {
  start() {
    this.toggleSubmitButton({ context: document.querySelector("div#bulk_search") });
  }

  toggleSubmitButton({ context = document }) {
    document.addEventListener("DOMContentLoaded", () => {
      const fileInput = context.querySelector("input[type='file']");
      const submitButton = context.querySelector("button[type='submit']");

      fileInput.addEventListener("change", function () {
        if (fileInput.files.length > 0) {
          submitButton.removeAttribute("disabled");
        } else {
          submitButton.setAttribute("disabled", "disabled");
        }
      });
    });
  }
}
