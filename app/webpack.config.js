const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const envalid = require('envalid')
const webpack = require('webpack')

const { makeValidator } = envalid
const nonEmptyString = makeValidator((input) => {
  if (typeof input === 'string' && input !== '') return input
  throw new Error(`Not a non-empty string: '${input}'`)
})

const stringifyKeys = obj => (sum, key) =>
  Object.assign({}, sum, { [key]: JSON.stringify(obj[key]) })

const { str, bool } = envalid
const env = envalid.cleanEnv(process.env, Object.assign({
  NODE_ENV: str({
    choices: ['production', 'development'],
    default: 'development',
  }),
  API_BASE_URL: nonEmptyString(),
}), {
  strict: true
})

module.exports = {
  entry: path.resolve(__dirname, './src/index.js'),
  mode: env.NODE_ENV,
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js'
  },
  plugins: [
    new HtmlWebpackPlugin({
      title: 'ProteoWizards',
      template: 'src/index.html'
    }),
    new webpack.DefinePlugin({
      'process.env': [
        'NODE_ENV',
        'API_BASE_URL',
      ].reduce(stringifyKeys(env), {}),
    }),
    new CopyWebpackPlugin([{
      from: 'public',
      to: '.'
    }])
  ]
}
