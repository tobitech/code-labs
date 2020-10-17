const os = require('os');
const async = require('async');
const fs = require('fs');
const Search = require('azure-cognitiveservices-visualsearch');
const CognitiveServicesCredentials = require('ms-rest-azure').CognitiveServicesCredentials;

let keyVar = '0b5936fbea864c829699f8b6fca5a4f0';
let credentials = new CognitiveServicesCredentials(keyVar);
let filePath = './resources/Data/image.jpg';

let visualSearchApiClient = new Search.VisualSearchClient(credentials);
let visualModels = visualSearchApiClient.models;

let fileStream = fs.createReadStream(filePath);
let visualSearchRequest = JSON.stringify({});
let visualSearchResults;

async function search() {
    try {
        visualSearchResults = await visualSearchApiClient.images.visualSearch({
            image: fileStream,
            knowledgeRequest: visualSearchRequest
        });
        console.log("Search visual search request with binary of dog image");
    } catch (err) {
        console.log("Encountered exception. " + err.message);
    }
    if (!visualSearchResults) {
        console.log("No visual search result data. ");
    } else {
        // Visual Search results
        if (visualSearchResults.image.imageInsightsToken) {
            console.log(`Uploaded image insights token: ${visualSearchResults.image.imageInsightsToken}`);
        }
        else {
            console.log("Couldn't find image insights token!");
        }
    
        // List of tags
        if (visualSearchResults.tags.length > 0) {
            let firstTagResult = visualSearchResults.tags[0];
            console.log(firstTagResult.displayName);
            console.log(`Visual search tag count: ${visualSearchResults.tags.length}`);
    
            // List of actions in first tag
            if (firstTagResult.actions.length > 0) {
                let firstActionResult = firstTagResult.actions[0];
                console.log(`First tag action count: ${firstTagResult.actions.length}`);
                console.log(`First tag action type: ${firstActionResult.actionType}`);
            }
            else {
                console.log("Couldn't find tag actions!");
            }
    
        }
        else {
            console.log("Couldn't find image tags!");
        }
    }
}

search();

/*
function sample() {
    async.series([
        async function () {

            let fileStream = fs.createReadStream(filePath);
            let visualSearchRequest = JSON.stringify({});
            let visualSearchResults;

            try {
                    visualSearchResults = await visualSearchApiClient.images.visualSearch({
                    image: fileStream,
                    knowledgeRequest: visualSearchRequest
                });
                console.log("Search visual search request with binary of dog image");
            } catch (err) {
                console.log("Encountered exception. " + err.message);
            }
            if (!visualSearchResults) {
                console.log("No visual search result data. ");
            } else {
                // Visual Search results
                if (visualSearchResults.image.imageInsightsToken) {
                    console.log(`Uploaded image insights token: ${visualSearchResults.image.imageInsightsToken}`);
                }
                else {
                    console.log("Couldn't find image insights token!");
                }

                // List of tags
                if (visualSearchResults.tags.length > 0) {
                    let firstTagResult = visualSearchResults.tags[0];
                    console.log(`Visual search tag count: ${visualSearchResults.tags.length}`);

                    // List of actions in first tag
                    if (firstTagResult.actions.length > 0) {
                        let firstActionResult = firstTagResult.actions[0];
                        console.log(`First tag action count: ${firstTagResult.actions.length}`);
                        console.log(`First tag action type: ${firstActionResult.actionType}`);
                    }
                    else {
                        console.log("Couldn't find tag actions!");
                    }

                }
                else {
                    console.log("Couldn't find image tags!");
                }
            }
        },
        function () {
            return new Promise((resolve) => {
                console.log(os.EOL);
                console.log("Finished running Visual-Search sample.");
                resolve();
            })
        }
    ], (err) => {
        throw (err);
    });
}

exports.sample = sample;
*/