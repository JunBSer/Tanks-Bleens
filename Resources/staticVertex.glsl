#version 330 core

layout(location = 0) in vec2 bPos;       
layout(location = 1) in vec2 bTexCoord;  

out vec2 TexCoordStatic; 

uniform mat4 model;       
uniform mat4 view;       
uniform mat4 projection; 

void main()
{
    gl_Position = projection * view * model * vec4(bPos, 0.0, 1.0); 
    TexCoordStatic = bTexCoord; 
}