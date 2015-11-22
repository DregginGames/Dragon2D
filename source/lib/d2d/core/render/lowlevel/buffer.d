/**
    Holds the abstraction layer for buffer objects
*/
module d2d.core.render.lowlevel.buffer;

import derelict.opengl3.gl3;
import gl3n.linalg;

/// Abstraction for all buffer opbjects
class Buffer
{
    /// The target for the buffer object
    enum TargetBufferObject {
        array = GL_ARRAY_BUFFER,
        atomicCounter = GL_ATOMIC_COUNTER_BUFFER,
        copyRead = GL_COPY_READ_BUFFER,
        drawIndirect = GL_DRAW_INDIRECT_BUFFER,
        dispatchIndirect = GL_DISPATCH_INDIRECT_BUFFER,
        elementArray = GL_ELEMENT_ARRAY_BUFFER,
        pixelPack = GL_PIXEL_PACK_BUFFER,
        pixelUnpack = GL_PIXEL_UNPACK_BUFFER,
        query = GL_QUERY_BUFFER,
        shaderStorage = GL_SHADER_STORAGE_BUFFER,
        texture = GL_TEXTURE_BUFFER,
        transformFeedback = GL_TRANSFORM_FEEDBACK_BUFFER,
        uniformBuffer = GL_UNIFORM_BUFFER
    }

    /// The usage mode for the data. Used by setData mainly
    enum UsageMode {
        streamDraw = GL_STREAM_DRAW,
        streamRead = GL_STREAM_READ,
        streamCopy = GL_STREAM_COPY,
        staticDraw = GL_STATIC_DRAW,
        staticRead = GL_STATIC_READ,
        staticCopy = GL_STATIC_COPY,
        dynamicDraw = GL_DYNAMIC_DRAW,
        dynamicRead = GL_DYNAMIC_READ,
        dynamicCopy = GL_DYNAMIC_COPY,
    }

    this(TargetBufferObject target = TargetBufferObject.array)
    {
        glGenBuffers(1,&_id);
        _target = target;
    }

    ~this()
    {
        if (_id != 0) {
            glDeleteBuffers(1,&_id);
        }
    }

    void setData(void* data, size_t size, UsageMode usage = UsageMode.staticDraw)
    {
        bind();
        glBufferData(_target, size, data, usage);
    }

    void bind()
    {
        auto b = _target in _currBufferBinding;
        if (b) {
            if(*b!=0 && *b==_id) {
                return;
            }
        }

        glBindBuffer(_target,_id);
    }

    @property GLuint id()
    {
        return _id;
    }
private:
    GLuint _id = 0;
    TargetBufferObject _target;
    static GLuint[TargetBufferObject] _currBufferBinding;
}



