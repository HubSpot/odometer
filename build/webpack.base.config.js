/**
 * 公共配置
 */
module.exports = {
  // 加载器
  module: {
    rules: [
      {
        test: /\.js$/,
        loader: ['babel-loader'],
        exclude: /(node_modules)/
      }
    ]
  }
};
