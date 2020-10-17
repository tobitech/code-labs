import API, { graphqlOperation } from '@aws-amplify/api'
import PubSub from '@aws-amplify/pubsub';

// GraphQL imports
import { createTodo } from './graphql/mutations'
import { listTodos } from './graphql/queries'
import { onCreateTodo } from './graphql/subscriptions'

import awsconfig from './aws-exports';
API.configure(awsconfig);
PubSub.configure(awsconfig);

// Interface elements
const QueryResult = document.getElementById('QueryResult');
const SubscriptionResult = document.getElementById('SubscriptionResult');

async function createNewTodo() {
    const todo = { name: "Use AppSync", description: "Realtime and Offline" }
    return await API.graphql(graphqlOperation(createTodo, { input: todo }))
}

const MutationButton = document.getElementById('MutationEventButton');
const MutationResult = document.getElementById('MutationResult');

MutationButton.addEventListener('click', (evt) => {
    MutationResult.innerHTML = `MUTATION RESULTS:`;
    createNewTodo().then((evt) => {
        MutationResult.innerHTML += `<p>${evt.data.createTodo.name} - ${evt.data.createTodo.description}</p>`
    })
});

// subscribe to data 
API.graphql(graphqlOperation(onCreateTodo)).subscribe({
    next: (evt) => {
        SubscriptionResult.innerHTML = `SUBSCRIPTION RESULTS`
        const todo = evt.value.data.onCreateTodo;
        SubscriptionResult.innerHTML += `<p>${todo.name} - ${todo.description}</p>`
    }
});

async function getData() {
    QueryResult.innerHTML = `QUERY RESULTS`;
    API.graphql(graphqlOperation(listTodos)).then((evt) => {
        evt.data.listTodos.items.map((todo, i) =>
            QueryResult.innerHTML += `<p>${todo.name} - ${todo.description}</p>`
        );
    })
}

getData();