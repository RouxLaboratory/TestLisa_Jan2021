%-- 06/19/2014 08:11:16 PM --%
TheStateEditor
ls *xml
help TheStateEditor
TheStateEditor('M002_S22_02252014')
ls *eegstat*
a = load('M002_S22_02252014.eegstates.mat');
a.StateInfo
a.StateInfo.fspec
a.StateInfo.fspec{1}
a.StateInfo.fspec{1}.fo(1:10)
help TheStateEditor
ls *states*
st = load('M002_S22_02252014-states.mat');
st
figure; plot(st.states)