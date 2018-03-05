--[[ @cond ___LICENSE___
-- Copyright (c) 2017 Zefiros Software.
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

zefiros = {
    name = nil,
    env = {}
}

function zefiros.testDefinition(name)

    configurations { "Test" }

    project(name)

    kind "ConsoleApp"
    files {
        "*.cpp"
    }

    zpm.uses "Zefiros-Software/GoogleTest"

    workspace()
end

function zefiros.setDefaults( name, options )

    zefiros.name = name
    local licenseheader = name .. "/" .. name .. ".licenseheader"    

    if not options then
        options = {}
    end

    if options.mayLink == nil then
        options.mayLink = true
    end

    local config = { "Release", "Debug", "OptDebug" }
    local lconf = {}
    if options.headerOnly then

        for _, c in ipairs( config ) do
            lconf = zpm.util.concat( lconf, {string.format( "HeaderOnly%s", c )} )
        end
    end
    config = zpm.util.concat( config, lconf )
    configurations( config )

    platforms { "x86_64", "x86" }
    startproject( name .. "-test" )
	location( name )
	objdir "bin/obj/"

	vectorextensions "SSE2"
    warnings "Extra"
    
    flags "MultiProcessorCompile"

    filter "system:not macosx"
        linkgroups "On"

    filter "system:not windows"
        configurations "Coverage"
    
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
        symbols "On"
        optimize "Off"
        
    filter "*OptDebug"
        targetsuffix "od"
        flags "LinkTimeOptimization"
        optimize "Speed"

    filter "*Release"        
        optimize "Speed"
        defines "NDEBUG"

    filter { "*Release", "system:not linux" }
        flags "LinkTimeOptimization"

    filter { "*OptDebug", "system:not linux" }
        flags "LinkTimeOptimization"
        
    filter "Coverage" 
        targetsuffix "cd"
        links "gcov"
        buildoptions "-coverage" 
        symbols "On"
        optimize "Off"
    
        objdir "!."
        targetdir "."
        
    filter "not HeaderOnly*"
        defines( options.noHeaderOnlySwitch )

    filter {}

    if os.isfile( licenseheader ) and os.isdir( "test" ) then
        os.copyfile( licenseheader, path.join("test", name .. ".licenseheader") )
    end 
			
	project( name .. "-test" )
				
		kind "ConsoleApp"		
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
			"test/**.cpp",
            "test/**.licenseheader"
			}

        excludes { 
            "test/extern/**",
            "test/assets/**"
         }
                     
        filter "not HeaderOnly*"
            if options.mayLink then
                links( name )
            end
            
        filter { "*Debug", "platforms:x86" }
            defines "PREFIX=X86D_"
        
        filter { "*Debug", "platforms:x86_64" }
            defines "PREFIX=X86_64D_"
        
        filter { "*Release", "platforms:x86" }
            defines "PREFIX=X86R_"
        
        filter { "*Release", "platforms:x86_64" }
            defines "PREFIX=X86_64R_"
        
        filter { "*Coverage", "platforms:x86" }
            defines "PREFIX=X86C_"
        
        filter { "*Coverage", "platforms:x86_64" }
            defines "PREFIX=X86_64C_"

        filter { "not *Coverage", "not *Release", "not *Debug" }
            defines "PREFIX=X_"

        filter {}
			
	project( name )
		targetname( name )
        kind "StaticLib"     
                
		includedirs {
			name .. "/include/"
			}				
		     
        files { 
            name .. "/include/**.hpp",
            name .. "/include/**.h",
            name .. "/**.licenseheader"
            }

        if not options.mayLink then
            zpm.util.writeAll(path.join(_MAIN_SCRIPT_DIR, "extern/dummy.cpp"), "void dummy() {}")
            files {
                "extern/dummy.cpp"
            }
        end
            
        filter "not HeaderOnly*"           
            files { 
                name .. "/src/**.cpp"
                }

        filter {}


    if os.isdir( "bench" ) then

        if os.isfile( licenseheader ) then
            os.copyfile( licenseheader, path.join("bench", name .. ".licenseheader") )
        end
    
        project( name .. "-bench" )
                    
            kind "ConsoleApp"            
            location "bench"
            
            zpm.uses {
                "Zefiros-Software/GoogleBenchmark"
            }
            
            includedirs {			
                name .. "/include/",
                "bench/"
                }	
            
            files { 
                "bench/**.h",
                "bench/**.cpp",
                "bench/**.licenseheader"
                }

            excludes { 
                "bench/extern/**",
                "bench/assets/**"
            }
                        
            filter "not HeaderOnly*"
                if options.mayLink then
                    links( name )
                end
        
            filter {}
    end
    
    workspace()
end

function zefiros.setTestZPMDefaults( name, options )

    if options == nil then
        options = {}
    end

    configurations { "Test" }

    platforms { "x86_64" }

    startproject( name .. "-zpm-test" )
	location "zpm"
	objdir "bin/obj/"

    optimize "Speed"
    warnings "Extra"
    
    flags "MultiProcessorCompile"
    
    --filter "system:not macosx"
    --    linkgroups "On"

    filter "platforms:x86_64"
        targetdir "bin/x86_64/"
        debugdir "bin/x86_64/"
        architecture "x86_64"

    filter {}
			
	project( name .. "-zpm-test" )
				
		kind "ConsoleApp"
        
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

function zefiros.env.vsversion()

    return os.getenv("VS_VERSION", "vs2015")
end

function zefiros.env.buildConfig()
    if _OPTIONS['build_configuration'] then
        return _OPTIONS['build_configuration']
    end

    return os.getenv("BUILD_CONFIG", "debug")
end

function zefiros.env.architecture()

    return os.getenv("BUILD_ARCHITECTURE", "x86_64")
end

function zefiros.env.project()

    if _ARGS[1] then
        return _ARGS[1]
    end
    return os.getenv("PROJECT")
end

function zefiros.env.projectDirectory()

    if _ARGS[2] then
        return _ARGS[2]
    end
    local result = os.getenv("PROJECT_DIRECTORY")
    if not result then
        
        local candidates = os.matchdirs("*/include/")
        if #candidates == 1 then
            result = candidates[1]:match("(.*)/include")
        end
    end

    return result
end

function zefiros.env.platform()

    local map = {
        x86 = "Win32",
        x86_64 = "x64",
        ARM = "ARM"
    }
    return map[zefiros.env.architecture()]
end

function zefiros.isZpmBuild()

    return zefiros.env.buildConfig() == "zpm"
end

function zefiros.isCoverageBuild()

    return zefiros.env.buildConfig() == "coverage"
end

function zefiros.isDebugBuild()

    return zefiros.env.buildConfig() == "debug"
end

function zefiros.installAstyle()
    local result, code = os.outputof("astyle --version")
    if code ~= 0 then

        if os.ishost("linux") then
            os.execute("sudo apt-get install astyle")
        elseif os.ishost("windows") then
            local destination = zpm.loader.http:downloadFromZipTo("https://kent.dl.sourceforge.net/project/astyle/astyle/astyle%203.0.1/AStyle_3.0.1_windows.zip")
            local out = path.join(zpm.env.getToolsDirectory(), "astyle.exe")
            if os.isfile(out) then
                zpm.util.hideProtectedFile(out)
            end
            local ok, err = os.copyfile(path.join(destination, "AStyle/bin/AStyle.exe"), out)
            assert(ok, ("Failed to copy astyle: '%s'"):format(err))
        elseif os.ishost("macosx") then
            os.execute("brew install astyle")
        end
    end
end

zpm.newaction {
    trigger = "build-ci",
    description = "Build this library with a default structure",
    execute = function()

        if os.ishost("windows") then
    
            if zefiros.isZpmBuild() then

                local current = os.getcwd()
            
                os.chdir(path.join(_MAIN_SCRIPT_DIR, "test"))

                os.executef("zpmd %s --skip-lock --update -verbose", zefiros.env.vsversion())   

                os.fexecutef("msbuild zpm/%s-ZPM.sln /property:Platform=x64 /m", zefiros.env.project())

                os.chdir(current)
            else
                
                os.executef("zpmd %s --skip-lock --update --verbose", zefiros.env.vsversion())   
                
                os.fexecutef("msbuild %s/%s.sln /m /property:Configuration=%s /property:Platform=%s", zefiros.env.projectDirectory(), zefiros.env.project(), zefiros.env.buildConfig(), zefiros.env.platform())
            end
        else
            if zefiros.isZpmBuild() then

                local current = os.getcwd()
            
                os.chdir(path.join(_MAIN_SCRIPT_DIR, "test"))

                os.executef("zpm gmake --update --skip-lock")   
            
                os.chdir(path.join(_MAIN_SCRIPT_DIR, "test/zpm"))

                os.fexecutef("make")

                os.chdir(current)
            else
                

                os.executef("zpm gmake --update --skip-lock --verbose")   
                
                local current = os.getcwd()
                os.chdir(path.join(_MAIN_SCRIPT_DIR, zefiros.env.projectDirectory()))

                os.fexecutef("make config=%s_%s", zefiros.env.buildConfig(), zefiros.env.architecture())

                os.chdir(current)
            end
        end
    end
}

zpm.newoption {
    trigger = "build_configuration",
    description = "Sets the kind of build you want to perform",
    value = "TYPE",
    allowed = {
        { "coverage", "Starts a coverage build."},
        { "release", "Starts a release build."},
        { "debug", "Starts a debug build."},
        { "zpm", "Starts a zpm build."}
     }
}

zpm.newaction {
    trigger = "test-definition",
    description = "Test this definition with a default structure",
    execute = function()

        if os.ishost("windows") then
            
            os.executef("zpmd vs2015 --skip-lock --verbose")   

            os.fexecutef("msbuild %s.sln /m /property:Configuration=Test /property:Platform=Win32", zefiros.env.project())
            os.fexecutef("bin\\Test\\%s.exe", zefiros.env.project())
        else

            os.executef("zpm gmake --skip-lock --verbose")   

            os.fexecutef("make")
            os.fexecutef("./bin/Test/%s", zefiros.env.project())
        end
    end
}

zpm.newaction {
    trigger = "deploy-ci-library",
    description = "Deploy this library with a default structure",
    execute = function()

        if os.ishost("linux") and zefiros.isCoverageBuild() then
            
            local codecov = path.join(zpm.env.getScriptPath(), ".codecov.yml")
            
            zpm.util.writeAll(path.join(_MAIN_SCRIPT_DIR, ".codecov.yml"), zpm.util.readAll(codecov))
            os.fexecutef("codecov")
        end

    end
}

zpm.newaction {
    trigger = "update-library",
    description = "Update this library to the newest config",
    execute = function()
        zefiros.installAstyle()

        zpm.util.writeAll(path.join(_MAIN_SCRIPT_DIR, ".gitignore"), zpm.util.readAll(path.join(zpm.env.getScriptPath(), ".gitignore")))
        zpm.util.writeAll(path.join(_MAIN_SCRIPT_DIR, "LICENSE.md"), zpm.util.readAll(path.join(zpm.env.getScriptPath(), "LICENSE.md")))

        local astylerc = path.join(_MAIN_SCRIPT_DIR, ".astylerc")
        zpm.util.writeAll(astylerc, zpm.util.readAll(path.join(zpm.env.getScriptPath(), "templates/.astylerc")))
        local dir = path.join(_MAIN_SCRIPT_DIR, zefiros.env.projectDirectory())
        os.executef("astyle --options=%s --recursive -i --exclude=\"extern\"  \"%s/*.cpp\"", astylerc, dir)
        os.executef("astyle --options=%s --recursive -i --exclude=\"extern\"  \"%s/*.h\"", astylerc, dir)
        os.executef("astyle --options=%s  --recursive -i --exclude=\"test/extern\"  \"%s/test/*.cpp\"  \"%s/test/*.h\"", astylerc, _MAIN_SCRIPT_DIR, _MAIN_SCRIPT_DIR)
        
        local olicense = string.format("extensions: .h .cpp .cc .hpp\n/**\n * %s\n */", zpm.util.readAll(path.join(zpm.env.getScriptPath(), "templates/mit.tmpl")):gsub("${years}", "%%CurrentYear%%"):gsub("${owner}", "Zefiros Software"):gsub("\n", "\n * "))
        local license = ""
        for line in zpm.util.magiclines(olicense) do
            license = license .. line:gsub("(%s*)$", "") .. "\n"
        end

        zpm.util.writeAll(path.join(dir, ("%s.licenseheader"):format(zefiros.env.projectDirectory())), license)

        os.execute("pip install --upgrade git+https://github.com/Zefiros-Software/licenseheaders.git")
        os.executef("python -m licenseheaders -t %s -o \"Zefiros Software\" -d \"%s\" -e \"%s/test/extern\"  \"%s/extern\" -y 2016-2018", 
                    path.join(zpm.env.getScriptPath(), "templates/mit.tmpl"), _MAIN_SCRIPT_DIR, _MAIN_SCRIPT_DIR, _MAIN_SCRIPT_DIR)
    end
}

zpm.newaction {
    trigger = "update-library-ci",
    description = "Update the ci configuration for this library",
    execute = function()

        local appveyor = zpm.util.readAll(path.join(zpm.env.getScriptPath(), "templates/.appveyor.yml")):gsub("{{PROJECT_NAME}}", zefiros.env.project()):gsub("{{PROJECT_DIRECTORY}}", zefiros.env.projectDirectory())
        zpm.util.writeAll(path.join(_MAIN_SCRIPT_DIR, ".appveyor.yml"), appveyor)
        local travis = zpm.util.readAll(path.join(zpm.env.getScriptPath(), "templates/.travis.yml")):gsub("{{PROJECT_NAME}}", zefiros.env.project()):gsub("{{PROJECT_DIRECTORY}}", zefiros.env.projectDirectory())
        zpm.util.writeAll(path.join(_MAIN_SCRIPT_DIR, ".travis.yml"), travis)

        if os.getenv("SLACK_TRAVIS_TOKEN") then

            local current = os.getcwd()
        
            os.chdir(_MAIN_SCRIPT_DIR)
            
            local hash = os.outputoff("travis encrypt \"%s\" --add notifications.slack", os.getenv("SLACK_TRAVIS_TOKEN"))
        
            os.chdir(current)
        end
    end
}

zpm.newaction {
    trigger = "update-definition",
    description = "Update this definition to the newest config",
    execute = function()
        zefiros.installAstyle()

        local root = path.join(_MAIN_SCRIPT_DIR, '../')
        zpm.util.writeAll(path.join(root, ".gitignore"), zpm.util.readAll(path.join(zpm.env.getScriptPath(), ".gitignore")))
        zpm.util.writeAll(path.join(root, "LICENSE.md"), zpm.util.readAll(path.join(zpm.env.getScriptPath(), "LICENSE.md")))

        local astylerc = path.join(root, ".astylerc")
        zpm.util.writeAll(astylerc, zpm.util.readAll(path.join(zpm.env.getScriptPath(), "templates/.astylerc")))
        local dir = path.join(root, zefiros.env.projectDirectory())
        os.executef("astyle --options=%s --recursive -i --exclude=\"extern\"  \"%s/*.cpp\"", astylerc, dir)
        os.executef("astyle --options=%s --recursive -i --exclude=\"extern\"  \"%s/*.h\"", astylerc, dir)
        os.executef("astyle --options=%s  --recursive -i --exclude=\"test/extern\" \"%stest/*.cpp\"  \"%stest/*.h\"", astylerc, root, root)
        
        local olicense = string.format("extensions: .h .cpp .cc .hpp\n/**\n * %s\n */", zpm.util.readAll(path.join(zpm.env.getScriptPath(), "templates/mit.tmpl")):gsub("${years}", "%%CurrentYear%%"):gsub("${owner}", "Zefiros Software"):gsub("\n", "\n * "))
        local license = ""
        for line in zpm.util.magiclines(olicense) do
            license = license .. line:gsub("(%s*)$", "") .. "\n"
        end

        os.execute("pip install --upgrade git+https://github.com/Zefiros-Software/licenseheaders.git")
        os.executef("python -m licenseheaders -t %s -o \"Zefiros Software\" -d \"%s\" -e \"%stest/extern\"  \"%s/extern\" -y 2016-2018", 
                    path.join(zpm.env.getScriptPath(), "templates/mit.tmpl"), root, root, root)
    end
}

zpm.newaction {
    trigger = "update-definition-ci",
    description = "Update the ci configuration for this definition",
    execute = function()

        local root = path.join(_MAIN_SCRIPT_DIR, '../')
        local appveyor = zpm.util.readAll(path.join(zpm.env.getScriptPath(), "templates/.appveyor-definition.yml")):gsub("{{PROJECT_NAME}}", zefiros.env.project())
        zpm.util.writeAll(path.join(root, ".appveyor.yml"), appveyor)
        local travis = zpm.util.readAll(path.join(zpm.env.getScriptPath(), "templates/.travis-definition.yml")):gsub("{{PROJECT_NAME}}", zefiros.env.project())
        zpm.util.writeAll(path.join(root, ".travis.yml"), travis)

        if os.getenv("SLACK_TRAVIS_TOKEN") then

            local current = os.getcwd()
        
            os.chdir(_MAIN_SCRIPT_DIR)
            
            local hash = os.outputoff("travis encrypt \"%s\" --add notifications.slack", os.getenv("SLACK_TRAVIS_TOKEN"))
        
            os.chdir(current)
        end
    end
}

zpm.newaction {
    trigger = "build-ci-library",
    description = "Build this library with a default structure",
    execute = function()

        os.fexecutef("g++ --version")
        os.fexecutef("clang --version")

        os.fexecutef("zpm run build-ci --verbose --skip-lock %s %s --build_configuration=%s", zefiros.env.project(), zefiros.env.projectDirectory(), zefiros.env.buildConfig())
        os.fexecutef("zpm run test-ci --verbose %s %s --build_configuration=%s", zefiros.env.project(), zefiros.env.projectDirectory(), zefiros.env.buildConfig())

    end
}

zpm.newaction {
    trigger = "build-ci-application",
    description = "Build this library with a default structure",
    execute = function()

        os.fexecutef("zpm run build-ci --verbose %s %s --build_configuration=%s", zefiros.env.project(), zefiros.env.projectDirectory(), zefiros.env.buildConfig())
        os.fexecutef("zpm run test-ci --verbose %s %s --build_configuration=%s", zefiros.env.project(), zefiros.env.projectDirectory(), zefiros.env.buildConfig())

    end
}

zpm.newaction {
    trigger = "test-ci",
    description = "Test this library with a default structure",
    execute = function()

        if os.ishost("windows") then       
            
            if zefiros.isZpmBuild() then
                os.fexecutef("cd test\\bin\\%s\\ && .\\%s-zpm-test.exe", zefiros.env.architecture(), zefiros.env.projectDirectory())     
            else
                if zefiros.isDebugBuild() then
                    os.fexecutef("cd bin\\%s\\ && .\\%s-testd.exe", zefiros.env.architecture(), zefiros.env.projectDirectory())     
                else
                    os.fexecutef("cd bin\\%s\\ && .\\%s-test.exe", zefiros.env.architecture(), zefiros.env.projectDirectory())     
                end
            end
        else
            
            if zefiros.isZpmBuild() then
                os.fexecutef("cd ./test/bin/%s/ && ./%s-zpm-test", zefiros.env.architecture(), zefiros.env.projectDirectory())     
            else
                if zefiros.isDebugBuild() then
                    os.fexecutef("cd ./bin/%s/ && ./%s-testd", zefiros.env.architecture(), zefiros.env.projectDirectory())    
                elseif zefiros.isCoverageBuild() then
                    os.fexecutef("./%s-testcd", zefiros.env.projectDirectory())     
                else
                    os.fexecutef("cd ./bin/%s/ && ./%s-test", zefiros.env.architecture(), zefiros.env.projectDirectory())     
                end
            end
        end
    end
}

function zefiros.onLoad()

    if os.getenv("TRAVIS") then

        local gccVersion = os.getenv("GCC_VERSION")
        if not gccVersion then
            gccVersion = "6"
        end

        if os.ishost("linux") and not zpm.loader.config(('install.module.zefiros-software.miniconda.gcc-%s'):format(gccVersion)) then 
            zpm.loader.config:set(('install.module.zefiros-software.miniconda.gcc-%s'):format(gccVersion), "installed", true)
            os.execute("sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y")
            os.execute("sudo apt-get -qq update -y")
        
            os.executef("sudo apt-get install g++-%s -y", gccVersion)
            os.executef("sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-%s 60", gccVersion)
            os.executef("sudo update-alternatives --config g++")

            if zefiros.env.architecture() == "x86" then
                --os.executef("sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-%s 60", gccVersion)
                --os.executef("sudo update-alternatives --config gcc")
                os.executef("sudo apt-get install gcc-%s-multilib g++-%s-multilib", gccVersion, gccVersion)
            end
        
            -- for coverage
            if zefiros.isCoverageBuild() then
                os.execute("sudo pip install git+https://github.com/codecov/codecov-python.git")
                os.executef("sudo update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-%s 60", gccVersion)
            end
        end
    end
end

return zefiros
