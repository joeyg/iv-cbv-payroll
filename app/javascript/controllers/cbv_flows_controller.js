import { Controller } from "@hotwired/stimulus"
import * as ActionCable from '@rails/actioncable'

import metaContent from "../utilities/meta";
import { loadArgyle, initializeArgyle, updateToken, fetchItems } from "../utilities/argyle"

function toOptionHTML({ id, name }) {
  return `
    <li class="grid-row">
      <div class="grid-col">
        <h4>${name}</h4>
        <p>San Francisco, CA</p>
      </div>
      <div class="grid-col flex-justify">
        <button
          data-action="click->cbv-flows#select"
          class="usa-button usa-button--outline"
          type="button"
        >
          Select
        </button>
      </div>
    </li>
  `;
}

export default class extends Controller {
  static targets = [
    /*"options"*/,
    "results",
    "searchTerms",
    "continue",
    "userAccountId",
    "fullySynced",
    "form",
    "modal"
  ];

  selection = null;

  argyle = null;

  argyleUserToken = null;

  cable = ActionCable.createConsumer();

  // TODO: information stored on the CbvFlow model can infer whether the paystubs are sync'd
  // by checking the value of payroll_data_available_from. We should make that the initial value.
  fullySynced = false;

  connect() {
    // check for this value when connected
    this.argyleUserToken = metaContent('argyle_user_token');
    this.cable.subscriptions.create({ channel: 'ArgylePaystubsChannel' }, {
      connected: () => {
        console.log("Connected to the channel:", this);
      },
      disconnected: () => {
        console.log("Disconnected");
      },
      received: (data) => {
        console.log("Received some data:", data);
        if (data.event === 'paystubs.fully_synced' || data.event === 'paystubs.partially_synced') {
          this.fullySynced = true;

          // this.formTarget.submit();
        }
      }
    });
  }

  onSignInSuccess(event) {
    this.userAccountIdTarget.value = event.accountId;
    this.argyle.close();
    this.modalTarget.click();
  }

  onAccountError(event) {
    console.log(event);
  }

  search(e) {
    e.preventDefault();
    const input = this.searchTermsTarget.value;

    fetchItems(input).then((results) => {
      this.resultsTarget.innerHTML = results.items.map(item => (toOptionHTML({ id: item.id, name: item.name }))).join('');
    });
  }

  select(event) {
    this.selection = null || event.detail.value;
    this.submit();
    // this.continueTarget.disabled = !this.selection;
  }

  submit() {
    loadArgyle()
      .then(Argyle => initializeArgyle(Argyle, this.argyleUserToken, {
        items: ['item_000002102', 'item_000002104'],
        onAccountConnected: this.onSignInSuccess.bind(this),
        onAccountError: this.onAccountError.bind(this),
        // Unsure what these are for!
        onDDSSuccess: () => { console.log('onDDSSuccess') },
        onDDSError: () => { console.log('onDDSSuccess') },
        onTokenExpired: updateToken,
      }))
      .then(argyle => this.argyle = argyle)
      .then(() => this.argyle.open());
  }
}
