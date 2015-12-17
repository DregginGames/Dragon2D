/*
    Holds the abstraction layer for vertex array objects
*/
module d2d.core.render.lowlevel.vao;

import derelict.opengl3.gl3;
import gl3n.linalg;

import d2d.core.render.lowlevel.buffer;

///Abstraction for Vertex Array Objects (i didnt name it like that. Shout at ARB)
class VAO
{
    enum DataType {
        signedByte = GL_BYTE, 
        unsignedByte = GL_UNSIGNED_BYTE,
        signedShort = GL_SHORT,
        unsignedShort = GL_UNSIGNED_SHORT,
        signedInt = GL_INT,
        unsignedInt = GL_UNSIGNED_INT,
        halfFloat = GL_HALF_FLOAT,
        floatType = GL_FLOAT, //cant use float/double/... because reserved name
        doubleType = GL_DOUBLE,
        fixed = GL_FIXED
    }

    this()
    {
        glGenVertexArrays(1,&_id);
    }

    ~this()
    {
        glDeleteVertexArrays(1,&_id);
        if (_currBoundVAO!=0 && _currBoundVAO==_id) {
            _currBoundVAO = 0;
        }
    }

    void bind()
    {
        if (_id != _currBoundVAO && _id != 0) {
            glBindVertexArray(_id);
            _currBoundVAO = _id;
        }
    }

    /**
        This function attaches a buffer to the vertex array object, or to be more percice, to the vertex attribute location specified by the parameter. 
        Its needed to give the compontent size and the datatype that is used by that buffer because it cant be determinated by just accessing the buffer.
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    */
    void attatchBuffer(uint index, Buffer buffer, int size, DataType type = DataType.floatType, uint stride = 0, size_t pointer = 0)
    {
        bind();
        buffer.bind();
        glEnableVertexAttribArray(index);
        glVertexAttribPointer(index, size,cast(uint) type, GL_TRUE, stride, cast(const void*)pointer);       
        _attachedBuffers[index] = buffer;
    }

    void disableAttribute(uint index)
    {
        glDisableVertexAttribArray(index);
        _attachedBuffers.remove(index);
    }
private:
    GLuint _id = 0;
    static GLuint _currBoundVAO;

    Buffer[uint] _attachedBuffers;
}
