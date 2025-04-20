var config = {}

config.mongoURI = {
    production: 'mongodb+srv://derrick:derrickdevopstest@cluster0.bm24bxo.mongodb.net/darkroom?retryWrites=true&w=majority',
    development: 'mongodb+srv://derrick:derrickdevopstest@cluster0.bm24bxo.mongodb.net/darkroom-dev?retryWrites=true&w=majority',
    test: 'mongodb+srv://derrick:derrickdevopstest@cluster0.bm24bxo.mongodb.net/darkroom-test?retryWrites=true&w=majority',
}

module.exports = config;
