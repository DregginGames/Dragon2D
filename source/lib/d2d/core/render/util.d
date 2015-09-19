/**
	d2d.core.render.util provides utulity functions for 2D and 3D rendering
*/
module d2d.core.render.util;

import std.conv;
import std.math;

import gl3n.linalg;

import d2d.core.base;
import d2d.system.env;

/** 
	Creates a Ortographic projection matrix 
	Defaults near plane to be 0 units away and far plane to be 100 units away 
*/
mat4 genOrtographicProjection(float width, float height, float near = 0.0, float far = 100.0)
{
	return mat4(
		[ 1.0f/width, 0.0f, 0.0f],
		[ 0.0f, 1.0f/height, 0.0f, 0.0f],
		[ 0.0f, 0.0f, -(2.0f/(far-near)), -((far+near)/(far-near))],
		[ 0.0f, 0.0f, 0.0f, 1.0f]);
}

/**
	Creates a worldToView (or just view) matrix based on a given positin in 2D space
*/
mat4 gen2DWorldToView(vec2 viewPosition, float viewBackoffset = 1.0f)
{
	return mat4.identity
		.translate(-viewPosition.x,-viewPosition.y, 0);
}

/**
	Creates a modelToWorld (or just model) matrix based on a given position in 2D space and rotation (around z) and scale (same for x- and y, for more complex compose matrix yourself).
*/
mat4 gen2DModelToWorld(vec2 modelPos, float alpha = 0.0f, float scale = 1.0f)
{
	return mat4.identity
		.translate(modelPos.x, modelPos.y, 0.0)
		.rotatez(alpha)
		.scale(scale,scale, 1.0f);
}

/**
	Creates 2 vertex arrays: one for the points (-0.5..0.5) and one wich is the uvs in the given range
*/
void genUVMappedVertexArray(out vec4[] vertices, out vec2[] uvs, float x=0.0f, float y=0.0f, float w=1.0f, float h=1.0f)
{
	//order: lower left, lower right, upper left, lower right, upper right, upper left
	vertices ~= vec4(-0.5f, -0.5f, 0.0f, 1.0f);
	uvs ~= vec2(x, y);
	vertices ~= vec4(0.5f, -0.5f, 0.0f, 1.0f);
	uvs ~= vec2(x+w, y);
	vertices ~= vec4(-0.5f, 0.5f, 0.0f, 1.0f);
	uvs ~= vec2(x, y+h);
	vertices ~= vec4(0.5f, -0.5f, 0.0f, 1.0f);
	uvs ~= vec2(x+w, y);
	vertices ~= vec4(0.5f, 0.5f, 0.0f, 1.0f);
	uvs ~= vec2(x+w, y+h);
	vertices ~= vec4(-0.5f, 0.5f, 0.0f, 1.0f);
	uvs ~= vec2(x+w, y);
}	

/**
	Clamps a position to the pixel-grid
	params:
	clampUpper: if set to true will use ceil insted of floor to bind the pixels
*/
vec2 toPixelGrid(vec2 pos, bool clampUpper = false)
{
	auto res = Base.getService!Env("d2d.env").resolution;

	auto ipos = toPixel(pos, clampUpper);
	return vec2(-1.0f + to!float(ipos.x)/to!float(res.x)*2.0f, 1.0f - to!float(ipos.y)/to!float(res.y)*2.0f);
}

/** 
	Clamps a position to the pixel-grid and returns the position in pixels, not normalized screen coordinates
	params:
		clampUpper: if set to true will use ceil insted of floor to bind the pixels
*/
vec2i toPixel(vec2 pos, bool clampUpper = false)
{
	// clamp pos to 0...1 of the pixel range (upper left corner = 0)
	vec2 normalPos = vec2((pos.x+1.0f)/2.0f, 1.0f-(pos.y+1.0f)/2.0f);
	auto res = Base.getService!Env("d2d.env").resolution;
	auto fPPos = vec2(pos.x*to!float(res.x), pos.y*to!float(res.y));
	vec2i newPos = vec2i(0,0);
	if (false == clampUpper) {
		newPos = vec2i(to!int(floor(fPPos.x)), to!int(floor(fPPos.y)));
	} else {
		newPos = vec2i(to!int(ceil(fPPos.x)), to!int(ceil(fPPos.y)));
	}

	return newPos;
}

/**
	Creates an rectangle wich has the same aspect ration as the window.
	It takes the height as reference for the calculation
*/
vec2 aspectRatioRectangle(float height)
{
	auto ar = Base.getService!Env("d2d.env").aspectRatio;
	return vec2(ar * height, height);
}