const initRebalanceForm = () => {
    $('#select-all-transactions-checkbox').on('click', e => {
        const checkbox = $('#select-all-transactions-checkbox');
        const checked = checkbox.prop('checked');

        $('.transaction-checkbox').prop('checked', checked);
    });

    $('#rebalance-button').on('click', e => {
        const transactionIds = [];
        const transactionAmounts = [];
        $('.transaction-id-container').each((i, e) => {
            const id = +e.innerHTML;
            if ($(`#transaction-${id}-checkbox`).prop('checked')) {
                transactionIds.push(+e.innerHTML);
                transactionAmounts.push(
                    +$(`#transaction-${id}-amount`)[0].innerHTML);
            }
        })
        const total = transactionAmounts.reduce((e, acc) => e + acc, 0);

        if (transactionIds.length === 0) {
            alert('Please select at least one transaction for rebalance.');
            return;
        }

        if (confirm(`Rebalancing will roll ${transactionIds.length} selected ` +
                    'transaction(s) listed below into one transaction occurring ' +
                    `today valued at $${total}. Are you sure?`)) {
            console.log(`Rolling up $${total} into one transaction.`);
            const csrfToken = $('#csrf-token-container')[0].innerHTML;
            console.log(csrfToken);

            transactionIds.forEach(id => {
                $.ajax({
                    url: `/transactions/${id}`,
                    type: 'DELETE',
                    data: {
                        _csrf_token: csrfToken,
                        id: id,
                    },
                    success: result => {
                        console.log(result);
                    },
                });
            });

            const today = new Date();
            const date_string =
                  `${today.getYear() + 1900}-${today.getMonth() + 1}-${today.getDate()}`;

            const data = JSON.stringify({
                _csrf_token: csrfToken,
                transaction: {
                    amount: total,
                    happened_at: date_string,
                    note: 'Rebalance',
                    account_id: $('#account-id-container')[0].innerHTML,
                },
            });

            console.log(data);

            $.ajax({
                url: '/transactions',
                type: 'POST',
                contentType: 'application/json',
                data: data,
                success: result => {
                    location.reload();
                }
            });

        }
    });
}

$(document).ready(initRebalanceForm);
