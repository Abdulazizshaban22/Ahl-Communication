import React, {useState, useRef, useEffect} from 'react';
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View, TextInput, TouchableOpacity, FlatList, I18nManager } from 'react-native';

const t = {
  ar: {
    title: 'أهلا شات',
    placeholder: 'اكتب رسالة…',
    send: 'إرسال',
    toggle: 'EN',
    hello: 'مرحبا 👋🏽',
    yaHala: 'يا هلا',
    botPrefix: 'أهلا يقول: '
  },
  en: {
    title: 'Ahla Chat',
    placeholder: 'Type a message…',
    send: 'Send',
    toggle: 'AR',
    hello: 'Hello 👋🏽',
    yaHala: 'Welcome',
    botPrefix: 'Ahla says: '
  }
};

export default function App() {
  const [lang, setLang] = useState('ar');
  const [msgs, setMsgs] = useState([
    { id: '1', mine: false, text: t['ar'].hello },
    { id: '2', mine: true, text: t['ar'].yaHala }
  ]);
  const [draft, setDraft] = useState('');
  const listRef = useRef(null);

  useEffect(() => {
    // Update first messages when language toggles
    setMsgs([
      { id: '1', mine: false, text: t[lang].hello },
      { id: '2', mine: true, text: t[lang].yaHala }
    ]);
  }, [lang]);

  const send = () => {
    const text = draft.trim();
    if (!text) return;
    const id = String(Date.now());
    setMsgs(prev => [...prev, { id, mine: true, text }]);
    setDraft('');
    // Demo "AI echo"
    setTimeout(() => {
      setMsgs(prev => [...prev, { id: id+'r', mine: false, text: t[lang].botPrefix + text }]);
      listRef.current?.scrollToEnd({ animated: true });
    }, 300);
  };

  return (
    <View style={[styles.container, lang === 'ar' ? styles.rtl : styles.ltr]}>
      <View style={styles.header}>
        <Text style={styles.title}>{t[lang].title}</Text>
        <TouchableOpacity onPress={() => setLang(lang === 'ar' ? 'en' : 'ar')} style={styles.toggle}>
          <Text style={styles.toggleText}>{t[lang].toggle}</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        ref={listRef}
        data={msgs}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{ padding: 12 }}
        onContentSizeChange={() => listRef.current?.scrollToEnd({ animated: true })}
        renderItem={({item}) => (
          <View style={[styles.row, item.mine ? styles.right : styles.left]}>
            <View style={[styles.bubble, item.mine ? styles.bubbleMine : styles.bubbleOther]}>
              <Text style={styles.msg}>{item.text}</Text>
            </View>
          </View>
        )}
      />

      <View style={styles.inputRow}>
        <TextInput
          style={[styles.input, lang === 'ar' ? styles.inputRtl : styles.inputLtr]}
          placeholder={t[lang].placeholder}
          placeholderTextColor="#7a7a7a"
          value={draft}
          onChangeText={setDraft}
        />
        <TouchableOpacity onPress={send} style={styles.sendBtn}>
          <Text style={styles.sendText}>{t[lang].send}</Text>
        </TouchableOpacity>
      </View>

      <StatusBar style="dark" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F6FBF9',
  },
  rtl: { direction: 'rtl' },
  ltr: { direction: 'ltr' },
  header: {
    paddingTop: 60,
    paddingBottom: 16,
    paddingHorizontal: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#E9F6F1',
    borderBottomColor: '#D5EEE6',
    borderBottomWidth: 1
  },
  title: {
    fontSize: 20,
    fontWeight: '700',
    color: '#2E4F42'
  },
  toggle: {
    backgroundColor: '#6CC5A3',
    paddingHorizontal: 14,
    paddingVertical: 6,
    borderRadius: 18
  },
  toggleText: { color: '#fff', fontWeight: '700' },
  row: { marginVertical: 4, flexDirection: 'row', alignItems: 'flex-end' },
  left: { justifyContent: 'flex-start' },
  right: { justifyContent: 'flex-end' },
  bubble: {
    maxWidth: '80%',
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: 16,
    shadowColor: '#000',
    shadowOpacity: 0.08,
    shadowRadius: 6,
    shadowOffset: { width: 0, height: 1 }
  },
  bubbleOther: { backgroundColor: 'rgba(0,0,0,0.06)' },
  bubbleMine: { backgroundColor: 'rgba(108,197,163,0.25)' },
  msg: { fontSize: 16, color: '#1b1b1b' },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 10,
    borderTopColor: '#D5EEE6',
    borderTopWidth: 1,
    backgroundColor: '#E9F6F1'
  },
  input: {
    flex: 1,
    backgroundColor: '#fff',
    borderRadius: 12,
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderWidth: 1,
    borderColor: '#DCEBE6',
    color: '#1b1b1b'
  },
  inputRtl: { textAlign: 'right' },
  inputLtr: { textAlign: 'left' },
  sendBtn: {
    marginStart: 8,
    backgroundColor: '#6CC5A3',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 12
  },
  sendText: { color: '#fff', fontWeight: '700' }
});
