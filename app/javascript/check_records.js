import { initAll } from "govuk-frontend";
import BulkSearchController from "./controllers/bulk_search_controller";

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

bulkSearch = new BulkSearchController();
bulkSearch.start();
