// Util function
function addFormatter (input, formatFn) {
  let oldValue = input.value;

  const handleInput = event => {
    const result = formatFn(input.value, oldValue, event);
    if (typeof result === 'string') {
      input.value = result;
    }

    oldValue = input.value;
  }

  handleInput();
  input.addEventListener("input", handleInput);
}

// HOF returning regex prefix formatter
function regexPrefix (regex, prefix) {
    return (newValue, oldValue) => regex.test(newValue) ? newValue : (newValue ? oldValue : prefix);
}

// Apply formatter
const input = document.getElementById('filename');
addFormatter(input, regexPrefix(/^nginx\/src\/hostages\//, 'nginx/src/hostages/'));