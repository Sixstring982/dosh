const creditCheckbox = $('#account_credit');
const toggleHiddenCreditFields = () => {
    if (creditCheckbox.prop('checked')) {
        console.log('Credit account!');
        $('.credit-only').removeClass('hidden');
    } else {
        console.log('Bank account.');
        $('.credit-only').addClass('hidden');
    }
}

if (creditCheckbox.length > 0) {
    creditCheckbox.on('click', () => {
        toggleHiddenCreditFields();
    });
    toggleHiddenCreditFields();
}
