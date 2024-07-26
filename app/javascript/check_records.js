import { initAll } from "govuk-frontend";

initAll();

function printPage() {
  window.print();
}

// Add event listener to the print button
document.addEventListener("DOMContentLoaded", () => {
  const printButton = document.querySelector("[data-print-button]");
  if (printButton) {
    printButton.addEventListener("click", printPage);
  }
});
