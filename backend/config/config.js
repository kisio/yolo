var config = {}

// MongoDB connection URIs for different environments
// Make sure to keep your credentials secure in production

config.mongoURI = {
    production: 'mongodb+srv://derrick:derrickdevopstest@cluster0.bm24bxo.mongodb.net/darkroom?retryWrites=true&w=majority',
    development: 'mongodb+srv://derrick:derrickdevopstest@cluster0.bm24bxo.mongodb.net/darkroom-dev?retryWrites=true&w=majority',
    test: 'mongodb+srv://derrick:derrickdevopstest@cluster0.bm24bxo.mongodb.net/darkroom-test?retryWrites=true&w=majority',
}

// Export the config object for use in the backend
module.exports = config;
