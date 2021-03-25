# Running Simulations on OSG

## Submit a job

```
condor_submit sim.sub
```

## Checking on running jobs

```
condor_q
```

Output:
```
-- Schedd: login04.osgconnect.net : <192.170.227.166:9618?... @ 03/25/21 09:59:29
OWNER  BATCH_NAME         SUBMITTED   DONE   RUN    IDLE   HOLD  TOTAL JOB_IDS
user e1d_sim_7552763   3/22 11:00   9975      5      _     20  10000 7552763.1984-9897
user e1d_sim_7590938   3/23 16:51   9892     18      _     90  10000 7590938.4-9954

Total for query: 133 jobs; 0 completed, 0 removed, 0 idle, 23 running, 110 held, 0 suspended
Total for tylern: 133 jobs; 0 completed, 0 removed, 0 idle, 23 running, 110 held, 0 suspended
Total for all users: 65146 jobs; 0 completed, 1 removed, 10923 idle, 28274 running, 25948 held, 0 suspended
```

Jobs under `HOLD` have failed for one reason or another. To move them back to `IDLE` run the command:

```
condor_release --all
```

## Remove a job

```
condor_rm JOB_ID # replace with the job id found from condor_q command
```
