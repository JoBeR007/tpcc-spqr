/*
 * Copyright 2020 by OLTPBenchmark Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

package com.oltpbenchmark.api;

import com.oltpbenchmark.types.DatabaseType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import static com.oltpbenchmark.api.BenchmarkModule.workConf;

/**
 * A LoaderThread is responsible for loading some portion of a
 * benchmark's database.
 * Note that each LoaderThread has its own database Connection handle.
 */
public abstract class LoaderThread implements Runnable {

    private static final Logger LOG = LoggerFactory.getLogger(LoaderThread.class);

    private final BenchmarkModule benchmarkModule;
    private int shardId;

    public LoaderThread(BenchmarkModule benchmarkModule) {
        this.benchmarkModule = benchmarkModule;
    }

    public LoaderThread(BenchmarkModule benchmarkModule, int shardId) {
        this.benchmarkModule = benchmarkModule;
        this.shardId = shardId;
    }

    @Override
    public final void run() {
        beforeLoad();
        if (workConf.getDatabaseType() != DatabaseType.SPQR) {
            try (Connection conn = benchmarkModule.makeConnection()) {
                load(conn);
            } catch (SQLException ex) {
                SQLException next_ex = ex.getNextException();
                String msg =
                    String.format(
                        "Unexpected error when loading %s database",
                        benchmarkModule.getBenchmarkName().toUpperCase());
                LOG.error(msg, next_ex);
                throw new RuntimeException(ex);
            } finally {
                afterLoad();
            }
        } else {
            try (Connection conn = benchmarkModule.makeShardConnection(shardId, false)) {
                load(conn);
            } catch (SQLException ex) {
                SQLException next_ex = ex.getNextException();
                String msg =
                    String.format(
                        "Unexpected error when loading %s database",
                        benchmarkModule.getBenchmarkName().toUpperCase());
                LOG.error(msg, next_ex);
                throw new RuntimeException(ex);
            } finally {
                afterLoad();
            }
        }
    }

    /**
     * This is the method that each LoaderThread has to implement
     *
     * @param conn
     * @throws SQLException
     */
    public abstract void load(Connection conn) throws SQLException;

    public void beforeLoad() {
        // useful for implementing waits for countdown latches, this ensures we open the connection right before its used to avoid stale connections
    }

    public void afterLoad() {
        // useful for counting down latches
    }


}
