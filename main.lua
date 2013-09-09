local texture = Texture.new("cross.png")

local effect = Effect.new("glsl",
[[
attribute vec4 POSITION0;
attribute vec2 TEXCOORD0;

uniform mat4 g_MVPMatrix;

varying vec2 position;
varying vec2 texCoord;

void main()
{
	texCoord = TEXCOORD0;
	position = POSITION0.xy;
	gl_Position = g_MVPMatrix * POSITION0;
}
]],
[[
#ifndef GL_ES
#define lowp
#define mediump
#define highp
#endif

uniform lowp sampler2D g_Texture;
uniform lowp vec4 g_Color;

uniform mediump vec2 lightPos;

varying highp vec2 texCoord;
varying mediump vec2 position;

void main()
{
	lowp vec3 color0 = texture2D(g_Texture, texCoord).rgb;
	lowp vec3 color1 = vec3(0.3, 0.3, 0.3);
	mediump vec3 normal = texture2D(g_Texture, texCoord + vec2(0.5, 0.0)).rgb * 2.0 - 1.0;
	mediump vec3 lightDir = normalize(vec3(lightPos.xy, 150) - vec3(position.xy, 0));
	mediump vec3 halfdir = normalize(normalize(lightDir) + vec3(0, 0, 1));

	lowp float diff = max(0.0, dot(normal, lightDir));
	mediump float nh = max(0.0, dot(normal, halfdir));
	mediump float spec = pow(nh, 10.0);
	
	gl_FragColor = g_Color * vec4(color0 * diff + color1 * spec, 1);
}
]])

local mesh = Mesh.new()
mesh:setVertexArray(0, 0, 512, 0, 512, 512, 0, 512)
mesh:setTextureCoordinateArray(0, 0, 512, 0, 512, 512, 0, 512)
mesh:setIndexArray(1, 2, 3, 1, 3, 4)
mesh:setTexture(texture)
mesh:setEffect(effect)

stage:addChild(mesh)

local function onEnterFrame(event)
	local x = 200 * math.cos(event.time * 2.1) + 256
	local y = 200 * math.sin(event.time * 1.4) + 256
	effect:setParameter("lightPos", x, y)
end

stage:addEventListener(Event.ENTER_FRAME, onEnterFrame)
