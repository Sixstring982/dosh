export const renderChart = (fromDate, toDate) => {
    const url = `/chart.json?fromDate=${formatDate(fromDate)}&toDate=${formatDate(toDate)}`;
    const rootId = 'forecast-root';

    if (document.getElementById(rootId)) {
        $.ajax({url: url, method: 'GET'}).done(e => {
            console.log(fromDate);
            console.log(toDate);
            console.log(e);
            const chart = Highcharts.chart('forecast-root', e);
        });
    }
};

const formatDate = date => {
    let year = '' + date.getFullYear();
    let month = '' + (date.getMonth() + 1);
    let day = '' + date.getDate();
    while (year.length < 4) {
        year = '0' + year;
    }
    while (month.length < 2) {
        month = '0' + month;
    }
    while (day.length < 2) {
        day = '0' + day;
    }

    return year + '-' + month + '-' + day;
}
