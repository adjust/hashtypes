BEGIN;
SET max_parallel_workers_per_gather=4;
DO $$
BEGIN
    IF current_setting('server_version_num')::int >= 160000 THEN
        EXECUTE 'SET debug_parallel_query = on';
    ELSE
        EXECUTE 'SET force_parallel_mode = on';
    END IF;
END $$;

CREATE TABLE parallel_test(i int, md md5hash, md2 md5hash) WITH (parallel_workers = 4);
INSERT INTO parallel_test (i, md, md2)
SELECT i, md5(i::text), md5((i + 1)::text)
FROM generate_series(1,1e6) i;

EXPLAIN (costs off,verbose)
SELECT COUNT(*) FROM parallel_test WHERE md > md2;

EXPLAIN (costs off,verbose)
SELECT md, COUNT(*) FROM parallel_test GROUP BY 1;
ROLLBACK;
