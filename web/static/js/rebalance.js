const initRebalanceButton = () => {
    $('#rebalance-button').on('click', e => {
        const transactionIds = [];
        $('.transaction-id-container').each((i, e) => {
            transactionIds.push(+e.innerHTML);
        })
        console.log(transactionIds);

        const transactionAmounts = [];
        $('.transaction-amount-container').each((i, e) => {
            transactionAmounts.push(+e.innerHTML);
        })

        if (confirm(`Rebalancing will roll all ${transactionIds.length} ` +
                    'transactions listed below into one transaction occurring ' +
                    'today. Are you sure?')) {
            const total = transactionAmounts.reduce((e, acc) => e + acc, 0);
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

$(document).ready(initRebalanceButton);
