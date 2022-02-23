# version 1.1

workflow simulation {
    String? container="tylern4/clas6:latest"
    File aaoradinp
    File gsiminp
    File useranain
    File parms
    Array[String] total
    
    scatter (num in total) {
      call generator {
        input: gen=aaoradinp,
              par=parms
      }
      call gsim {
        input: gsimin=gsiminp,
              aaoin=generator.aao,
              par=parms
      }
      call recsis {
        input: uncooked=gsim.gsimbos,
                userana=useranain,
                par=parms
      }
    }

}

task generator {

      File gen
      File par
   
    runtime {
        docker: "tylern4/clas6:latest"
        time: "00:10:00"
        memory: "1G"
        cpu: 1
        node: 1
        nwpn: 1
        poolname: "nickspool"
        shared: 1
    }

    command<<<
      export MYSQLINC=/usr/include/mysql
      export MYSQLLIB=/usr/lib64/mysql
      export CLAS6=/usr/local/clas-software/build
      export PATH=$CLAS6/bin:$PATH
      export CERN=/usr/local/cernlib/x86_64_rhel6
      export CERN_LEVEL=2005
      export CERN_ROOT=$CERN/$CERN_LEVEL
      export CVSCOSRC=$CERN/$CERN_LEVEL/src
      export PATH=$CERN/$CERN_LEVEL/src:$PATH
      export CERN_LIB=$CERN_ROOT/lib
      export CERNLIB=$CERN_ROOT/lib
      export CERN_BIN=$CERN_ROOT/bin
      export LD_LIBRARY_PATH=$ROOTSYS/lib:$CLAS_TOOL/slib/Linux:$CLAS6/lib

      export ROOTSYS=/usr/local/root
      source $ROOTSYS/bin/thisroot.sh
      echo "par" ${par}
      echo "gen" ${gen}
      
      tar -xvf ${par}

      export CLAS_PARMS=$PWD/parms
      env
      aao_rad < ${gen}
      >>>

    output {
       File aao = "aao_rad.evt"
    }
}

task gsim {

    File gsimin
    File par
    File aaoin

    runtime {
        docker: "tylern4/clas6:latest"
        time: "00:10:00"
        memory: "1G"
        cpu: 1
        node: 1
        nwpn: 1
        poolname: "nickspool"
        shared: 1
    }

    command<<<
      export MYSQLINC=/usr/include/mysql
      export MYSQLLIB=/usr/lib64/mysql
      export CLAS6=/usr/local/clas-software/build
      export PATH=$CLAS6/bin:$PATH
      export CERN=/usr/local/cernlib/x86_64_rhel6
      export CERN_LEVEL=2005
      export CERN_ROOT=$CERN/$CERN_LEVEL
      export CVSCOSRC=$CERN/$CERN_LEVEL/src
      export PATH=$CERN/$CERN_LEVEL/src:$PATH
      export CERN_LIB=$CERN_ROOT/lib
      export CERNLIB=$CERN_ROOT/lib
      export CERN_BIN=$CERN_ROOT/bin
      export LD_LIBRARY_PATH=$ROOTSYS/lib:$CLAS_TOOL/slib/Linux:$CLAS6/lib

      export CLAS_CALDB_PASS=""
      export CLAS_CALDB_RUNINDEX="RunIndex"

      export RECSIS_RUNTIME=$PWD/recsis
      mkdir -p $RECSIS_RUNTIME

      export CLAS_CALDB_HOST=clasdb.jlab.org
      export CLAS_CALDB_USER=clasreader

      export ROOTSYS=/usr/local/root
      source $ROOTSYS/bin/thisroot.sh

      tar -xvf ${par}

      export CLAS_PARMS=$PWD/parms

      gsim_bat -nomcdata -ffread ${gsimin} -mcin ${aaoin} -bosout gsim.bos
      gpp -ouncooked.bos -a2.35 -b2.35 -c2.35 -f0.97 -P0x1b -R23500 gsim.bos
      >>>

    output {
       File gsimbos = "uncooked.bos"
    }
 }

task recsis {

    File uncooked
    File userana
    File par

    runtime {
        docker: "tylern4/clas6:latest"
        time: "00:10:00"
        memory: "1G"
        cpu: 1
        node: 1
        nwpn: 1
        poolname: "nickspool"
        shared: 1
    }

    command<<<
      export MYSQLINC=/usr/include/mysql
      export MYSQLLIB=/usr/lib64/mysql
      export CLAS6=/usr/local/clas-software/build
      export PATH=$CLAS6/bin:$PATH
      export CERN=/usr/local/cernlib/x86_64_rhel6
      export CERN_LEVEL=2005
      export CERN_ROOT=$CERN/$CERN_LEVEL
      export CVSCOSRC=$CERN/$CERN_LEVEL/src
      export PATH=$CERN/$CERN_LEVEL/src:$PATH
      export CERN_LIB=$CERN_ROOT/lib
      export CERNLIB=$CERN_ROOT/lib
      export CERN_BIN=$CERN_ROOT/bin
      export LD_LIBRARY_PATH=$ROOTSYS/lib:$CLAS_TOOL/slib/Linux:$CLAS6/lib

      export CLAS_CALDB_PASS=""
      export CLAS_CALDB_RUNINDEX="RunIndex"

      export RECSIS_RUNTIME=$PWD/recsis
      mkdir -p $RECSIS_RUNTIME

      export CLAS_CALDB_HOST=clasdb.jlab.org
      export CLAS_CALDB_USER=clasreader

      export ROOTSYS=/usr/local/root
      source $ROOTSYS/bin/thisroot.sh

      tar -xvf ${par}

      export CLAS_PARMS=$PWD/parms
      ln -s ${uncooked} .
      ls -latr

      user_ana -t ${userana}
      h10maker -rpm cooked.bos all.root
      >>>

    output {
       File root = "all.root"
    }
 }