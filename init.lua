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

    if options == nil then
        options = {}
    end

    local config = { "Debug", "Release", "OptimisedDebug" }
    local lconf = {}
    if options.headerOnly ~= nil and options.headerOnly then

        for _, c in ipairs( config ) do
            lconf = zpm.util.concat( lconf, {string.format( "HeaderOnly%s", c )} )
        end
    end
    config = zpm.util.concat( config, lconf )
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
        defines "NDEBUG"
        
    filter "Coverage" 
        targetsuffix "cd"
        links "gcov"
        buildoptions "-coverage" 
    
    filter "not HeaderOnly*"
        defines( options.noHeaderOnlySwitch )
			
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

        excludes { 
            "test/extern/**",
            "test/assets/**"
         }
                     
        filter "not HeaderOnly*"
            links( name )
            
        filter { "*Debug", "platforms:x86" }
            defines "PREFIX=X86D_"
        
        filter { "*Debug", "platforms:x86_64" }
            defines "PREFIX=X86_64D_"
        
        filter { "*Release", "platforms:x86" }
            defines "PREFIX=X86R_"
        
        filter { "*Release", "platforms:x86_64" }
            defines "PREFIX=X86_64R_"

        filter {}
			
	project( name )
		targetname( name )	 
		kind "StaticLib"
                
		includedirs {
			name .. "/include/"
			}				
		     
        files { 
            name .. "/include/**.hpp",
            name .. "/include/**.h"
            }
            
        filter "not HeaderOnly*"                
            files { 
			    name .. "/src/**.cpp"
                }
    
    workspace()
end

function zefiros.setTestZPMDefaults( name, options )

    if options == nil then
        options = {}
    end

    configurations( { "Test" } )

    platforms { "x86" }

    startproject( name .. "-test" )
	location( "zpm" )
	objdir "bin/obj/"

	warnings "Extra"
	
	flags {
		"Unicode",
		"C++11"
	}
    
    filter "platforms:x86"
        targetdir "bin/x86/"
        debugdir "bin/x86/"
        architecture "x86"
			
	project( name .. "-zpm-test" )
				
		kind "ConsoleApp"
		flags "WinMain"
        
        zpm.uses "Zefiros-Software/GoogleTest"
		
		includedirs "./"
		
		files { 
			"**.h",
			"**.cpp"
			}

        excludes { 
            "extern/**",
            "assets/**"
         }
        
        defines "PREFIX=ZPM_"
    
    workspace()
end

return zefiros