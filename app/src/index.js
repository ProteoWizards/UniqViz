const API_BASE_URL = process.env.API_BASE_URL

const jStat = require('jstat')

console.log('API_BASE_URL:', API_BASE_URL)

const canvas = document.getElementById('canvas')
// const W = canvas.width = 700 //window.innerWidth
// const H = canvas.height = 700 //window.innerHeight
// document.body.appendChild(canvas)

async function main () {
  const data = await fetch(API_BASE_URL + '/').then(res => res.json())
  console.log('data:', data)

  var ctx = canvas.getContext("2d")
  var slider = document.getElementById("myRange")

  const nodes = data.map(obj => ([obj.uniqueness, obj.angle]))

  const radius = 302
  const ringRadius = 9; // 7
  const centerX = 316
  const centerY = 320
  let redlineX = 20
  let redlineY = 20
  const ringPercentage = 0.01


  const background = new Image()
  background.src = "bhack-background.svg"

  // Make sure the image is loaded first otherwise nothing will draw.
  background.onload = function(){
    ctx.drawImage(background,0,0)
    drawDiagram(1, 1)
  }

  function changeColor(){
	id = document.getElementById("dropdown").value;
	console.log(id);
  }

  slider.oninput = function() {
    let alpha, beta

    if (this.value > 500) {
      alpha = (this.value-400)/100
      beta = 1
    } else {
      alpha = 1
      beta = (600-this.value)/100
    }

    drawDiagram(alpha, beta)
  }

  function drawDiagram(alpha, beta) {
    ctx.clearRect(0, 0, canvas.width,canvas.height)
    ctx.drawImage(background,0,0)

    for (let j = 0; j < nodes.length; j++) {
      const scale = jStat.beta.cdf( 1-nodes[j][0], alpha, beta )
      const x = Math.cos(nodes[j][1])*radius*scale
      const y = Math.sin(nodes[j][1])*radius*scale

      if (j == Math.floor(nodes.length*(1 - ringPercentage))) {
        redlineX = x
        redlineY = y
      }

      ctx.beginPath()
      ctx.arc(centerX + x, centerY + y, ringRadius*(1-scale) , 0, 2 * Math.PI)

	  var grd=ctx.createRadialGradient(centerX + x,centerY + y,0,centerX + x,centerY + y,ringRadius*(1-scale));
	  grd.addColorStop(0,"white");
	  grd.addColorStop(1,"transparent");
      ctx.fillStyle = grd;
      ctx.fill()
    }

    ctx.beginPath()
    ctx.arc(centerX , centerY , Math.sqrt(Math.pow(redlineX, 2)+Math.pow(redlineY, 2)) , 0, 2 * Math.PI)
    ctx.strokeStyle="red"
    ctx.stroke()
  }
}

document.getElementById('goselect').onchange = function(e) {
  console.log(e.target.value)
}

main()
  .then(res => res ? console.log(res) : undefined)
  .catch(console.error)
