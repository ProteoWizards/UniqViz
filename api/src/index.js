const path = require('path')
const cp = require('child_process')

const express = require('express')
const bodyParser = require('body-parser')
const morgan = require('morgan')
const cors = require('cors')
const ndjson = require('ndjson')

const PORT = process.env.PORT || 4000
const HOSTNAME = process.env.HOSTNAME || 'localhost'
const RSCRIPTS_DIR = process.env.RSCRIPTS_DIR || path.resolve(__dirname, '../../rscripts')

const app = express()

app.use(morgan('dev'))
app.use(cors())

app.get('/', (req, res) => {
  const rscript = cp.spawn('/usr/local/bin/Rscript', [ path.resolve(RSCRIPTS_DIR, 'get-uniqueness.R') ], {
  // const rscript = cp.spawn('Rscript', [ path.resolve(RSCRIPTS_DIR, 'get-uniqueness.R') ], {
    env: {
      DATA_DIR: path.resolve(__dirname, '../../data')
    }
  })

  rscript.on('error', (err) => {
    console.log(err)
    return res.status(500)
  })

  // Concat into array and send at once
  // More advanced would send streaming text to client and client parses
  const collected = []

  rscript.stdout
    .pipe(ndjson.parse())
    .on('data', (data) => collected.push(data))
    // .on('data', (data) => collected.push(data.toString()))
    .on('end', () => {
      return res.send(collected)
    })
    .on('error', (err) => {
      console.log(err)
      return res.status(500)
    })
})

app.get('/gocategory/:gocategory', (req, res) => {
  // res.send(req.params.gocategory)
  const rscript = cp.spawn('Rscript', [ path.resolve(RSCRIPTS_DIR, 'selectChoices.R'), req.params.gocategory ], {
    env: {
      DATA_DIR: path.resolve(__dirname, '../../data')
    }
  })
  rscript.on('error', (err) => {
    console.error(err)
    return res.status(500)
  })

  // Concat into array and send at once
  // More advanced would send streaming text to client and client parses
  const collected = []

  // rscript.stdout
  //   .pipe(process.stdout)

  // rscript.stderr
  //   .pipe(process.stderr)

  rscript.stdout
    .pipe(ndjson.parse())
    .on('data', (data) => collected.push(data))
    // .on('data', (data) => collected.push(data.toString()))
    .on('end', () => {
      return res.send(collected)
    })
    .on('error', (err) => {
      console.error(err)
      return res.status(500)
    })
})

app.listen(PORT)
  .on('listening', () => console.log(`Express server listening on ${HOSTNAME}:${PORT}`))
