import { Elm } from '../src/Main';

const app = Elm.Main;
const rootElementSelector = '#app';
const rootElement = document.querySelector(rootElementSelector)

app.init({
    node: rootElement
});