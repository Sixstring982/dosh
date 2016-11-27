const chooseHandler = () => {
    switch ($('#period-select').val()) {
    case 'monthly': {
        $('.monthly-only').removeClass('hidden');
        $('.n-days-only').addClass('hidden');
        $('#recurrence_repeat_period').val('');
        $('#recurrence_start_date').val('');
        break;
    }
    case 'n-days': {
        $('.monthly-only').addClass('hidden');
        $('.n-days-only').removeClass('hidden');
        $('#recurrence_day_of_month').val('');
        break;
    }
    default: {
        $('.monthly-only').addClass('hidden');
        $('.n-days-only').addClass('hidden');
        $('#recurrence_repeat_period').val('');
        $('#recurrence_start_date').val('');
        $('#recurrence_day_of_month').val('');
        break;
    }
    }
};

$('#period-select').on('change', chooseHandler);

if ($('#recurrence_repeat_period').val()) {
    $('#period-n-days').prop('selected', true);
    chooseHandler();
}

if ($('#recurrence_day_of_month').val()) {
    $('#period-monthly').prop('selected', true);
    chooseHandler();
}
