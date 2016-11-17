import { renderChart } from './chart';

let fromDate = new Date();
let toDate = new Date(fromDate.getFullYear(), fromDate.getMonth(), fromDate.getDate() + 30);

const fromPicker = $('#from-date').pickadate({
    onSet: e => {
        if (e.select) {
            fromDate = new Date(e.select);
            renderChart(fromDate, toDate);
        }
    }
}).pickadate('picker');
fromPicker.set('select', fromDate.getTime());

const toPicker = $('#to-date').pickadate({
    onSet: e => {
        if (e.select) {
            toDate = new Date(e.select);
            renderChart(fromDate, toDate);
        }
    }
}).pickadate('picker');
toPicker.set('select', toDate.getTime());
