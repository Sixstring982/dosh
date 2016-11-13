$('.logout-link').click(() => {
    $.ajax({url: '/logout', method: 'DELETE'}).done(() => {
        window.location.reload();
    });
});
