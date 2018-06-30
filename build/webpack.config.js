const path = require('path');
const webpack = require('webpack');
const merge = require('webpack-merge')
const webpackBaseConfig = require('./webpack.base.config.js');
const ParallelUglifyPlugin = require('webpack-parallel-uglify-plugin')

process.env.NODE_ENV = 'production'

module.exports = merge(webpackBaseConfig, {
  entry: {
    main: './odometer.js'
  },
  output: {
    path: path.resolve(__dirname, '../'),
    filename: 'odometer.min.js',
    library: 'odometer',
    libraryTarget: 'umd',
    umdNamedDefine: true
  },
  plugins: [
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: '"production"'
      }
    }),
    new ParallelUglifyPlugin({
      uglifyJS:{
        output: {
          comments: false
        },
        compress: {
          warnings: false
        }
      }
    })
  ]
});
