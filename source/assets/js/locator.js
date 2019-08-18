(function () {

  function getSchemaPath({ standardNumber, partNumber, nsPrefix, version }) {
    return `${standardNumber}/-${partNumber}/${nsPrefix}/${version}`;
  }

  class SchemaLocator {
    constructor() {
      this.form = null;
      this.handleLocateClick = this.handleLocateClick.bind(this);
    }
    render() {
      const template = document.querySelector('#schemaLocator');
      let el = document.importNode(template.content, true);

      this.form = el.children[0];
      this.form.querySelector('button[name=locate]').
        addEventListener('click', this.handleLocateClick);

      return el;
    }
    getInputValue(inputName) {
      return this.form.querySelector(`input[name=${inputName}]`).value;
    }
    getFormValues() {
      return {
        standardNumber: this.getInputValue('standardNumber'),
        partNumber: this.getInputValue('partNumber'),
        nsPrefix: this.getInputValue('nsPrefix'),
        version: this.getInputValue('version'),
      };
    }
    handleLocateClick(evt) {
      evt.preventDefault();
      window.location.href = `https://schemas.isotc211.org/${getSchemaPath(this.getFormValues())}`;
    }
  }

  let schemaHeader = document.querySelector('.section.locator > h2');
  schemaHeader.parentNode.insertBefore(
    (new SchemaLocator).render(),
    schemaHeader.nextSibling);

}());
