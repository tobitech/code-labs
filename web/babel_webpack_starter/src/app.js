import { person, sayHello } from './lib';

// console.log(person.name);

// console.log(sayHello("brad"));

// the async keyword will make a function return a Promise automatically...
async function getPosts() {
    const response = await fetch('https://jsonplaceholder.typicode.com/posts');

    const data = await response.json();

    return data;
}

getPosts().then(posts => console.log(posts));