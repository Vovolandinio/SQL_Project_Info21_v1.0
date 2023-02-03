-- 1 case

CALL pr_p2p_check (
    'Bennett',
    'Diluc',
    'C5_s21_decimal',
    'Start',
    '09:00:00'
);

CALL pr_p2p_check (
    'Bennett',
    'Diluc',
    'C5_s21_decimal',
    'Success',
    '09:20:00'
);

CALL pr_verter_check (
    'Bennett',
    'C5_s21_decimal',
    'Start',
    '09:21:00'
);

CALL pr_verter_check (
    'Bennett',
    'C5_s21_decimal',
    'Success',
    '09:22:00'
);

--

-- 2 case
CALL pr_p2p_check (
    'Klee',
    'Diluc',
    'C3_s21_string+',
    'Start',
    '09:00:00'
);

CALL pr_p2p_check (
    'Klee',
    'Diluc',
    'C3_s21_string+',
    'Success',
    '09:30:00'
);

CALL pr_verter_check (
    'Klee',
    'C3_s21_string+',
    'Start',
    '09:31:00'
);

CALL pr_verter_check (
    'Klee',
    'C3_s21_string+',
    'Failure',
    '09:32:00'
);

-- 3 case

CALL pr_p2p_check (
    'Dori',
    'Keqing',
    'C2_SimpleBashUtils',
    'Start',
    '19:00:00'
);

CALL pr_p2p_check (
    'Dori',
    'Keqing',
    'C2_SimpleBashUtils',
    'Success',
    '19:25:00'
);

CALL pr_verter_check (
    'Dori',
    'C2_SimpleBashUtils',
    'Start',
    '19:26:00'
);

CALL pr_verter_check (
    'Dori',
    'C2_SimpleBashUtils',
    'Success',
    '19:27:00'
);