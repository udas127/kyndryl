SELECT
    t.機械番号,
    SUM(t.稼働時間) AS 総稼働時間
FROM (
    SELECT
        run.機械番号,
        SUM(
            CASE
                WHEN cld.稼働 = 1 THEN
                    CASE
                        -- 終了日時よりも停止日時が早い場合かつ（開始日時がカレンダー日である、かつ停止日時がカレンダー日である場合）
                        WHEN run.停止日時 IS NOT NULL AND run.停止日時 < run.終了日時 AND cld.カレンダー日 = DATE(run.開始日時) AND cld.カレンダー日 = DATE(run.停止日時) THEN
                            CASE
                                -- 開始日時が9時よりも早く、停止日時が18時よりも遅い場合
                                WHEN TIME(run.開始日時) < TIME('09:00:00') AND TIME(run.停止日時) > TIME('18:00:00') THEN
                                    (TIME_TO_SEC(TIME('18:00:00')) - TIME_TO_SEC(TIME('09:00:00'))) / 3600.0
                                -- 開始日時が9時よりも遅く、停止日時が18時よりも早い場合
                                WHEN TIME(run.開始日時) >= TIME('09:00:00') AND TIME(run.停止日時) < TIME('18:00:00') THEN
                                    (TIME_TO_SEC(TIME(run.停止日時)) - TIME_TO_SEC(TIME(run.開始日時))) / 3600.0
                                -- 開始日時が9時よりも早く、停止日時が18時よりも早い場合
                                WHEN TIME(run.開始日時) < TIME('09:00:00') AND TIME(run.停止日時) < TIME('18:00:00') THEN
                                    (TIME_TO_SEC(TIME(run.停止日時)) - TIME_TO_SEC(TIME('09:00:00'))) / 3600.0
                                -- 開始日時が9時よりも遅く、停止日時が18時よりも遅い場合
                                WHEN TIME(run.開始日時) >= TIME('09:00:00') AND TIME(run.停止日時) >= TIME('18:00:00') THEN
                                    (TIME_TO_SEC(TIME('18:00:00')) - TIME_TO_SEC(TIME(run.開始日時))) / 3600.0
                                ELSE
                                    0.0
                            END
                        -- 終了日時よりも停止日時が早い場合かつ（開始日時がカレンダー日である、かつ停止日時はカレンダー日ではない場合）
                        WHEN run.停止日時 IS NOT NULL AND run.停止日時 < run.終了日時 AND cld.カレンダー日 = DATE(run.開始日時) AND cld.カレンダー日 <> DATE(run.停止日時) THEN
                            CASE
                                -- 開始日時が9時よりも早い場合
                                WHEN TIME(run.開始日時) < TIME('09:00:00') THEN
                                    (TIME_TO_SEC(TIME('18:00:00')) - TIME_TO_SEC(TIME('09:00:00'))) / 3600.0
                                -- 開始日時が9時よりも遅い場合
                                WHEN TIME(run.開始日時) >= TIME('09:00:00') THEN
                                    (TIME_TO_SEC(TIME('18:00:00')) - TIME_TO_SEC(TIME(run.開始日時))) / 3600.0
                                ELSE
                                    0.0
                            END
                        -- 終了日時よりも停止日時が早い場合かつ（開始日時がカレンダー日ではない、かつ停止日時がカレンダー日である場合）
                        WHEN run.停止日時 IS NOT NULL AND run.停止日時 < run.終了日時 AND cld.カレンダー日 <> DATE(run.開始日時) AND cld.カレンダー日 = DATE(run.停止日時) THEN
                            CASE
                                -- 停止日時が18時よりも早い場合
                                WHEN TIME(run.停止日時) < TIME('18:00:00') THEN
                                    (TIME_TO_SEC(TIME(run.停止日時)) - TIME_TO_SEC(TIME('09:00:00'))) / 3600.0
                                -- 停止日時が18時よりも遅い場合
                                WHEN TIME(run.停止日時) >= TIME('18:00:00') THEN
                                    (TIME_TO_SEC(TIME('18:00:00')) - TIME_TO_SEC(TIME('09:00:00'))) / 3600.0
                                ELSE
                                    0.0
                            END
                        -- 終了日時よりも停止日時が早い場合かつ（カレンダー日が作成日時でない、かつ停止日時でもない）
                        WHEN run.停止日時 IS NOT NULL AND run.停止日時 < run.終了日時 AND cld.カレンダー日 <> DATE(run.作成日) AND cld.カレンダー日 <> DATE(run.停止日時) THEN
                            0.0
                        -- 停止日時がNULLまたは終了日時と同じ場合かつ（開始日時がカレンダー日である、かつ終了日時はカレンダー日である場合）
                        WHEN (run.停止日時 IS NULL OR run.停止日時 = run.終了日時) AND cld.カレンダー日 = DATE(run.開始日時) AND cld.カレンダー日 = DATE(run.終了日時) THEN
                            CASE
                                -- 開始日時が9時よりも早く、終了日時が18時よりも遅い場合
                                WHEN TIME(run.開始日時) < TIME('09:00:00') AND TIME(run.終了日時) > TIME('18:00:00') THEN
                                    (TIME_TO_SEC(TIME('18:00:00')) - TIME_TO_SEC(TIME('09:00:00'))) / 3600.0
                                -- 開始日時が9時よりも遅く、終了日時が18時よりも早い場合
                                WHEN TIME(run.開始日時) >= TIME('09:00:00') AND TIME(run.終了日時) < TIME('18:00:00') THEN
                                    (TIME_TO_SEC(TIME(run.終了日時)) - TIME_TO_SEC(TIME(run.開始日時))) / 3600.0
                                -- 開始日時が9時よりも早く、終了日時が18時よりも早い場合
                                WHEN TIME(run.開始日時) < TIME('09:00:00') AND TIME(run.終了日時) < TIME('18:00:00') THEN
                                    (TIME_TO_SEC(TIME(run.終了日時)) - TIME_TO_SEC(TIME('09:00:00'))) / 3600.0
                                -- 開始日時が9時よりも遅く、終了日時が18時よりも遅い場合
                                WHEN TIME(run.開始日時) >= TIME('09:00:00') AND TIME(run.終了日時) >= TIME('18:00:00') THEN
                                    (TIME_TO_SEC(TIME('18:00:00')) - TIME_TO_SEC(TIME(run.開始日時))) / 3600.0
                                ELSE
                                    0.0
                            END
                        -- 停止日時がNULLまたは終了日時と同じ場合かつ（開始日時がカレンダー日である、かつ終了日時はカレンダー日ではない場合）
                        WHEN (run.停止日時 IS NULL OR run.停止日時 = run.終了日時) AND cld.カレンダー日 = DATE(run.開始日時) AND cld.カレンダー日 <> DATE(run.終了日時) THEN
                            CASE
                                -- 開始日時が9時よりも早い場合
                                WHEN TIME(run.開始日時) < TIME('09:00:00') THEN
                                    (TIME_TO_SEC(TIME('18:00:00')) - TIME_TO_SEC(TIME('09:00:00'))) / 3600.0
                                -- 開始日時が9時よりも遅い場合
                                WHEN TIME(run.開始日時) >= TIME('09:00:00') THEN
                                    (TIME_TO_SEC(TIME('18:00:00')) - TIME_TO_SEC(TIME(run.開始日時))) / 3600.0
                                ELSE
                                    0.0
                            END
                        -- 停止日時がNULLまたは終了日時と同じ場合かつ（開始日時がカレンダー日ではない、かつ終了日時がカレンダー日である場合）
                        WHEN (run.停止日時 IS NULL OR run.停止日時 = run.終了日時) AND cld.カレンダー日 <> DATE(run.開始日時) AND cld.カレンダー日 = DATE(run.終了日時) THEN
                            CASE
                                -- 終了日時が18時よりも早い場合
                                WHEN TIME(run.終了日時) < TIME('18:00:00') THEN
                                    (TIME_TO_SEC(TIME(run.終了日時)) - TIME_TO_SEC(TIME('09:00:00'))) / 3600.0
                                -- 終了日時が18時よりも遅い場合
                                WHEN TIME(run.終了日時) >= TIME('18:00:00') THEN
                                    (TIME_TO_SEC(TIME('18:00:00')) - TIME_TO_SEC(TIME('09:00:00'))) / 3600.0
                                ELSE
                                    0.0
                            END
                        -- 停止日時がNULLまたは終了日時と同じ場合かつ（カレンダー日が作成日でない、かつ終了日時でもない）
                        WHEN (run.停止日時 IS NULL OR run.停止日時 = run.終了日時) AND cld.カレンダー日 <> DATE(run.作成日) AND cld.カレンダー日 <> DATE(run.終了日時) THEN
                            0.0
                        ELSE
                            0.0
                    END
                ELSE
                    0.0
            END
        ) AS 稼働時間
    FROM
        機械稼働表 AS run
    INNER JOIN
        カレンダーテーブル AS cld ON cld.カレンダー日 >= DATE(run.開始日時) AND cld.カレンダー日 <= DATE(run.終了日時)
    GROUP BY
        run.機械番号
) AS t
GROUP BY
    t.機械番号;
