#cython: language_level = 3
from cython.parallel import parallel
from libc.stdio cimport printf
"""
    GOAL: implement nogil option in cdef class (extension types)
    and native memory manager (refcount based) that does not
    depend on cpython's memory manager and that does not require GIL.
    
    HINT: look at C++ standard library (that works very nicely with Cython)

    Cython documentation if here: http://docs.cython.org/en/latest/
    
    Basic usage: http://docs.cython.org/en/latest/src/quickstart/build.html
    
    Tutorial: http://docs.cython.org/en/latest/src/tutorial/cython_tutorial.html
    
    Language: http://docs.cython.org/en/latest/src/userguide/language_basics.html
    
    Extension types: http://docs.cython.org/en/latest/src/userguide/extension_types.html
        
        Extension Types are the "pure cython" classes that I want to be able to
        use without depending on cpython GIL (and in essence runtime, memory manager, etc.)
        
    Cython memory allocation: http://docs.cython.org/en/latest/src/tutorial/memory_allocation.html
    
    Parallelism: http://docs.cython.org/en/latest/src/userguide/parallelism.html
    
        Explains how nogil is posisble in cython for anything that
        only relies on C libraries that are multi-threaded
"""



# cdef class SomeMemory:
cdef cypclass SomeMemory:
  """
  This is a cdef class which is also called
  a extensino type. It is a kind of C struct
  that also acts as a python object.
  
  We would like to be able to define "nogil"
  extension types:
  
  ccdef class SomeMemory:
  
  where all methods are "nogil" and memory
  allocation does not depend on python runtime
  """
  int a;
  double b;

  void __init__(self, int a, double b):
      this.a = a
      this.b = b

  void __dealloc__(self):
      pass

  void foo1(self):
    """
    It is possible to define native C/Cython methods
    that release the GIL (cool...)
    """
    this.a += 3

  void foo2(self):
    """
    It is possible to define native C/Cython methods
    that release the GIL (cool...)
    """
    this.a = 42
    
  # Not allowed to define pure Python function in the extension type with nogil option now
  # since we want this extension type is CPython free
  # def baz(self):
  #  """
  #  It is also possible to define standard python
  #  methods
  #  """
  #  pass
    
    
# cdef bar(): # it is currently impossible to release GIL
cdef double bar1() nogil: # yet this is what we would like to
    """
    This is a pure "cython method" which we would like to
    be able to declare with nogil option but this requires
    to first introduce the concept of nogil in cdef class
    """
    cdef SomeMemory o1 = SomeMemory(1, 1.0) # Call init and get an object

    o1.foo1()
    
    return o1.a

cdef double bar2() nogil: # yet this is what we would like to
    cdef SomeMemory o2 = SomeMemory(2, 2.0)

    o2.foo2()
    
    return o2.a

cpdef baz1():
    """
    This method is both callable from python and pure "cython".
    It can call both cdef methods and usual python functions
    """
    return bar1()

cpdef baz2():
    """
    This method is both callable from python and pure "cython".
    It can call both cdef methods and usual python functions
    """
    return bar2()

def bag():
    return str(baz1()) + '\n' + str(baz2())
