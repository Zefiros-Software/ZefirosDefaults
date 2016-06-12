--[[ @cond ___LICENSE___
-- Copyright (c) 2016 Koen Visscher, Paul Visscher and individual contributors.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
-- @endcond
--]]

zefiros = {}

function zefiros.setDefaults( name, options )

    local config = { "Debug", "Release", "OptimisedDebug", "Coverage" }
    if options.configurations ~= nil then
        config = zpm.util.concat( config, options.configurations )
    end
    configurations( config )

    platforms { "x86_64", "x86" }

    startproject( name .. "-test" )
	location( name .. "/" )
	objdir "bin/obj/"

	vectorextensions "AVX"
	warnings "Extra"
	
	flags {
		"Unicode",
		"C++11"
	}

    filter "system:not windows"
        configurations { "Coverage" }
    
    filter "platforms:x86"
        targetdir "bin/x86/"
        debugdir "bin/x86/"
        architecture "x86"
    
    filter "platforms:x86_64"
        targetdir "bin/x86_64/"
        debugdir "bin/x86_64/"
        architecture "x86_64"
        
    filter "*Debug"
        targetsuffix "d"
        defines "DEBUG"

        flags "Symbols"
        optimize "Off"
        
    filter "*OptimisedDebug"
        targetsuffix "od"
        flags "LinkTimeOptimization"
        optimize "Speed"

    filter "*Release"
        optimize "Speed"
        
    filter "Coverage" 
        targetsuffix "cd"
        links "gcov"
        buildoptions "-coverage"
        
    zpm.buildLibraries()
				
	filter {}
			
	project( name .. "-test" )
				
		kind "ConsoleApp"
		flags "WinMain"
		
		location "test/"
        
        zpm.uses {
			"Zefiros-Software/GoogleTest"
		}
		
		includedirs {			
			name .. "/include/",
			"test/"
			}	
		
		files { 
			"test/**.h",
			"test/**.cpp"
			}
            
        filter { "*Debug", "platforms:x86" }
            defines "PREFIX=X86D_"
        
        filter { "*Debug", "platforms:x86_64" }
            defines "PREFIX=X86_64D_"
        
        filter { "*Release", "platforms:x86" }
            defines "PREFIX=X86R_"
        
        filter { "*Release", "platforms:x86_64" }
            defines "PREFIX=X86_64R_"
			
	project( name )
		targetname( name )	 
		kind "StaticLib"
                
		includedirs {
			name .. "/include/"
			}				
		
		files { 
			name .. "/include/**.h"
			}
    
    workspace()
end

return zefiros