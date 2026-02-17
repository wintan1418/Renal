import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["items", "item"]

  addItem(event) {
    event.preventDefault()
    const timestamp = new Date().getTime()
    const template = this.buildItemTemplate(timestamp)
    this.itemsTarget.insertAdjacentHTML("beforeend", template)
  }

  removeItem(event) {
    event.preventDefault()
    const item = event.target.closest("[data-invoice-builder-target='item']")
    if (!item) return

    const destroyInput = item.querySelector("[data-invoice-builder-target='destroy']")
    if (destroyInput) {
      // For persisted items, mark for destruction
      destroyInput.value = "1"
      item.style.display = "none"
    } else {
      // For new items, remove from DOM
      item.remove()
    }
  }

  fillPrice(event) {
    // Could be extended to auto-fill price based on service selection via AJAX
    // Left as a hook for future enhancement
  }

  recalculate(event) {
    // Could be extended to show a running total in the form
    // Left as a hook for future enhancement
  }

  buildItemTemplate(index) {
    return `
      <div class="grid grid-cols-12 gap-2 items-end p-3 bg-base-200 rounded-xl" data-invoice-builder-target="item">
        <input type="hidden" name="invoice[invoice_items_attributes][${index}][_destroy]" value="false" data-invoice-builder-target="destroy" />

        <div class="col-span-12 sm:col-span-4 form-control">
          <label class="label label-text text-xs">Service</label>
          <select name="invoice[invoice_items_attributes][${index}][service_id]"
                  class="select select-bordered select-sm w-full"
                  data-action="change->invoice-builder#fillPrice">
            <option value="">Select service...</option>
          </select>
        </div>

        <div class="col-span-12 sm:col-span-3 form-control">
          <label class="label label-text text-xs">Description</label>
          <input type="text"
                 name="invoice[invoice_items_attributes][${index}][description]"
                 class="input input-bordered input-sm w-full"
                 placeholder="Override description..." />
        </div>

        <div class="col-span-4 sm:col-span-2 form-control">
          <label class="label label-text text-xs">Qty</label>
          <input type="number"
                 name="invoice[invoice_items_attributes][${index}][quantity]"
                 min="1" value="1"
                 class="input input-bordered input-sm w-full"
                 data-action="input->invoice-builder#recalculate" />
        </div>

        <div class="col-span-6 sm:col-span-2 form-control">
          <label class="label label-text text-xs">Unit Price (kobo)</label>
          <input type="number"
                 name="invoice[invoice_items_attributes][${index}][unit_price_cents]"
                 min="0" step="100" value="0"
                 class="input input-bordered input-sm w-full"
                 data-action="input->invoice-builder#recalculate" />
        </div>

        <div class="col-span-2 sm:col-span-1 flex items-end pb-1">
          <button type="button"
                  class="btn btn-ghost btn-sm btn-square text-error"
                  data-action="click->invoice-builder#removeItem">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4">
              <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
    `
  }
}
