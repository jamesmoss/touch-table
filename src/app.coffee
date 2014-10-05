artnet = require('artnet-node')
app = require('express')();
server = require('http').Server(app);
io = require('socket.io')(server);
converter = require("color-convert")();

server.listen(8999);

app.get '/', (req, res) ->
  res.sendFile(__dirname + '/index.html');

x = 0
y = 0

io.on 'connection', (socket) ->
  socket.on 'coords', (data) ->
    x = data.x
    y = data.y

universes = []

for i in [0..3]
  universes[i] = new artnet.Client.ArtNetClient('192.168.0.24', 6454)
  universes[i].UNIVERSE = [i+1, 0]


logify = (position) ->
  return position
  minp = 0;
  maxp = 100;
  minv = Math.log(0);
  maxv = Math.log(100);
  scale = (maxv-minv) / (maxp-minp);
  Math.exp(minv + scale * (position-minp))

# dmx_dta[0] = 255 #B
# dmx_dta[1] = 0; #G
# dmx_dta[2] = 255 #R


i = 0

tick = () ->

  rgb = converter.hsv(Math.round(x * 3.6), 100, logify(y)).rgb()

  if !rgb
    return

  #console.log x, y

  dmx_data = new Array(420);

  for i in [0..420] by 3
    dmx_data[i]   = rgb[2]
    dmx_data[i+1] = rgb[1]
    dmx_data[i+2] = rgb[0]

  for i in [0..3]
    uni = universes[i]
    uni.send(dmx_data)

setInterval(tick, 40)


#client.send(dmx_dta);
console.log(23);
#client2.send(dmx_dta);
console.log(34);

