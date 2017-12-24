

if zpm.setting("installCI") then

    local gccVersion = os.getenv("GCC_VERSION")
    if not gccVersion then
        gccVersion = "6"
    end

    if os.ishost("linux") then 
        os.execute("sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y")
        os.execute("sudo apt-get update -y")
    
        os.execute("sudo apt-get install gcc-%s g++-%s -y", version, version)
        os.execute("sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-%s 60", version)
        os.execute("sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-%s 60", version)
        os.execute("sudo update-alternatives --config gcc")
        os.execute("sudo update-alternatives --config g++")
        os.execute("sudo apt-get install gcc-%s-multilib g++-%s-multilib", version, version)
    
        -- for coverage
        os.execute("sudo pip install codecov")
    end
end