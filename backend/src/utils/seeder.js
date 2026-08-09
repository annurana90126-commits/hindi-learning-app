const mongoose = require('mongoose');
const Lesson = require('../models/Lesson');
const Word = require('../models/Word');
require('dotenv').config({ path: '../../.env' });

const lessons = [
  {
    title: 'Greetings',
    titleHindi: 'अभिवादन',
    description: 'Learn basic Hindi greetings',
    unitNumber: 1,
    lessonNumber: 1,
    xpReward: 10,
    order: 1,
  },
  {
    title: 'Numbers 1–10',
    titleHindi: 'संख्याएं',
    description: 'Count from one to ten in Hindi',
    unitNumber: 1,
    lessonNumber: 2,
    xpReward: 10,
    order: 2,
  },
  {
    title: 'Colors',
    titleHindi: 'रंग',
    description: 'Learn the names of colors in Hindi',
    unitNumber: 1,
    lessonNumber: 3,
    xpReward: 10,
    order: 3,
  },
  {
    title: 'Family',
    titleHindi: 'परिवार',
    description: 'Family member vocabulary',
    unitNumber: 1,
    lessonNumber: 4,
    xpReward: 10,
    order: 4,
  },
  {
    title: 'Food & Drinks',
    titleHindi: 'खाना-पीना',
    description: 'Common food and drink vocabulary',
    unitNumber: 2,
    lessonNumber: 1,
    xpReward: 15,
    order: 5,
  },
  {
    title: 'Animals',
    titleHindi: 'जानवर',
    description: 'Names of common animals',
    unitNumber: 2,
    lessonNumber: 2,
    xpReward: 15,
    order: 6,
  },
];

// Words mapped by lesson title
const wordsByLesson = {
  Greetings: [
    { hindi: 'नमस्ते', english: 'Hello', transliteration: 'Namaste', exampleHindi: 'नमस्ते, आप कैसे हैं?', exampleEnglish: 'Hello, how are you?' },
    { hindi: 'धन्यवाद', english: 'Thank you', transliteration: 'Dhanyavaad', exampleHindi: 'धन्यवाद आपकी मदद के लिए।', exampleEnglish: 'Thank you for your help.' },
    { hindi: 'हाँ', english: 'Yes', transliteration: 'Haan', exampleHindi: 'हाँ, मैं ठीक हूँ।', exampleEnglish: 'Yes, I am fine.' },
    { hindi: 'नहीं', english: 'No', transliteration: 'Nahin', exampleHindi: 'नहीं, मुझे नहीं पता।', exampleEnglish: 'No, I do not know.' },
    { hindi: 'माफ़ करना', english: 'Sorry / Excuse me', transliteration: 'Maaf Karna', exampleHindi: 'माफ़ करना, मुझे देर हो गई।', exampleEnglish: 'Sorry, I am late.' },
    { hindi: 'फिर मिलेंगे', english: 'See you again', transliteration: 'Phir Milenge', exampleHindi: 'ठीक है, फिर मिलेंगे।', exampleEnglish: 'Okay, see you again.' },
    { hindi: 'शुभ प्रभात', english: 'Good morning', transliteration: 'Shubh Prabhat', exampleHindi: 'शुभ प्रभात! आज का दिन अच्छा हो।', exampleEnglish: 'Good morning! Have a nice day.' },
    { hindi: 'शुभ रात्रि', english: 'Good night', transliteration: 'Shubh Ratri', exampleHindi: 'शुभ रात्रि, मीठे सपने।', exampleEnglish: 'Good night, sweet dreams.' },
  ],
  'Numbers 1–10': [
    { hindi: 'एक', english: 'One', transliteration: 'Ek', exampleHindi: 'मेरे पास एक किताब है।', exampleEnglish: 'I have one book.' },
    { hindi: 'दो', english: 'Two', transliteration: 'Do', exampleHindi: 'मेरे दो हाथ हैं।', exampleEnglish: 'I have two hands.' },
    { hindi: 'तीन', english: 'Three', transliteration: 'Teen', exampleHindi: 'तीन बजे मिलते हैं।', exampleEnglish: 'Let us meet at three.' },
    { hindi: 'चार', english: 'Four', transliteration: 'Chaar', exampleHindi: 'चार दिन बाद आना।', exampleEnglish: 'Come after four days.' },
    { hindi: 'पाँच', english: 'Five', transliteration: 'Paanch', exampleHindi: 'पाँच आम दे दो।', exampleEnglish: 'Give me five mangoes.' },
    { hindi: 'छह', english: 'Six', transliteration: 'Chhah', exampleHindi: 'छह बजे घर आना।', exampleEnglish: 'Come home at six.' },
    { hindi: 'सात', english: 'Seven', transliteration: 'Saat', exampleHindi: 'सात दिन में एक हफ्ता।', exampleEnglish: 'Seven days make a week.' },
    { hindi: 'आठ', english: 'Eight', transliteration: 'Aath', exampleHindi: 'आठ बजे खाना खाएंगे।', exampleEnglish: 'We will eat at eight.' },
    { hindi: 'नौ', english: 'Nine', transliteration: 'Nau', exampleHindi: 'नौ बच्चे खेल रहे हैं।', exampleEnglish: 'Nine children are playing.' },
    { hindi: 'दस', english: 'Ten', transliteration: 'Das', exampleHindi: 'दस मिनट में आता हूँ।', exampleEnglish: 'I will come in ten minutes.' },
  ],
  Colors: [
    { hindi: 'लाल', english: 'Red', transliteration: 'Laal', exampleHindi: 'यह लाल गुलाब है।', exampleEnglish: 'This is a red rose.' },
    { hindi: 'नीला', english: 'Blue', transliteration: 'Neela', exampleHindi: 'आसमान नीला है।', exampleEnglish: 'The sky is blue.' },
    { hindi: 'हरा', english: 'Green', transliteration: 'Hara', exampleHindi: 'घास हरी है।', exampleEnglish: 'The grass is green.' },
    { hindi: 'पीला', english: 'Yellow', transliteration: 'Peela', exampleHindi: 'सूरज पीला है।', exampleEnglish: 'The sun is yellow.' },
    { hindi: 'सफेद', english: 'White', transliteration: 'Safed', exampleHindi: 'दूध सफेद है।', exampleEnglish: 'Milk is white.' },
    { hindi: 'काला', english: 'Black', transliteration: 'Kaala', exampleHindi: 'रात काली है।', exampleEnglish: 'The night is black.' },
    { hindi: 'नारंगी', english: 'Orange', transliteration: 'Narangi', exampleHindi: 'नारंगी फल नारंगी रंग का है।', exampleEnglish: 'The orange fruit is orange.' },
    { hindi: 'गुलाबी', english: 'Pink', transliteration: 'Gulaabi', exampleHindi: 'उसकी ड्रेस गुलाबी है।', exampleEnglish: 'Her dress is pink.' },
  ],
  Family: [
    { hindi: 'माँ', english: 'Mother', transliteration: 'Maa', exampleHindi: 'मेरी माँ बहुत अच्छी है।', exampleEnglish: 'My mother is very good.' },
    { hindi: 'पिताजी', english: 'Father', transliteration: 'Pitaji', exampleHindi: 'पिताजी ऑफिस गए हैं।', exampleEnglish: 'Father has gone to office.' },
    { hindi: 'भाई', english: 'Brother', transliteration: 'Bhai', exampleHindi: 'मेरा भाई स्कूल में पढ़ता है।', exampleEnglish: 'My brother studies in school.' },
    { hindi: 'बहन', english: 'Sister', transliteration: 'Bahan', exampleHindi: 'मेरी बहन डॉक्टर है।', exampleEnglish: 'My sister is a doctor.' },
    { hindi: 'दादा', english: 'Grandfather', transliteration: 'Daada', exampleHindi: 'दादा बहुत बुद्धिमान हैं।', exampleEnglish: 'Grandfather is very wise.' },
    { hindi: 'दादी', english: 'Grandmother', transliteration: 'Daadi', exampleHindi: 'दादी कहानी सुनाती हैं।', exampleEnglish: 'Grandmother tells stories.' },
    { hindi: 'बेटा', english: 'Son', transliteration: 'Beta', exampleHindi: 'मेरा बेटा बहुत होशियार है।', exampleEnglish: 'My son is very smart.' },
    { hindi: 'बेटी', english: 'Daughter', transliteration: 'Beti', exampleHindi: 'उनकी बेटी डॉक्टर बनेगी।', exampleEnglish: 'Their daughter will become a doctor.' },
  ],
  'Food & Drinks': [
    { hindi: 'पानी', english: 'Water', transliteration: 'Paani', exampleHindi: 'मुझे पानी चाहिए।', exampleEnglish: 'I need water.' },
    { hindi: 'खाना', english: 'Food', transliteration: 'Khaana', exampleHindi: 'खाना बहुत अच्छा है।', exampleEnglish: 'The food is very good.' },
    { hindi: 'दूध', english: 'Milk', transliteration: 'Doodh', exampleHindi: 'बच्चे दूध पीते हैं।', exampleEnglish: 'Children drink milk.' },
    { hindi: 'चाय', english: 'Tea', transliteration: 'Chai', exampleHindi: 'भारत में चाय बहुत पसंद की जाती है।', exampleEnglish: 'Tea is very popular in India.' },
    { hindi: 'रोटी', english: 'Bread / Chapati', transliteration: 'Roti', exampleHindi: 'रोटी और दाल मेरा पसंदीदा खाना है।', exampleEnglish: 'Roti and dal is my favourite food.' },
    { hindi: 'चावल', english: 'Rice', transliteration: 'Chaawal', exampleHindi: 'चावल और दाल खाएंगे।', exampleEnglish: 'We will eat rice and dal.' },
    { hindi: 'फल', english: 'Fruit', transliteration: 'Phal', exampleHindi: 'फल खाना सेहत के लिए अच्छा है।', exampleEnglish: 'Eating fruit is good for health.' },
    { hindi: 'सब्ज़ी', english: 'Vegetable', transliteration: 'Sabzi', exampleHindi: 'आज सब्ज़ी बाज़ार जाना है।', exampleEnglish: 'I need to go to the vegetable market today.' },
  ],
  Animals: [
    { hindi: 'कुत्ता', english: 'Dog', transliteration: 'Kutta', exampleHindi: 'कुत्ता भौंक रहा है।', exampleEnglish: 'The dog is barking.' },
    { hindi: 'बिल्ली', english: 'Cat', transliteration: 'Billi', exampleHindi: 'बिल्ली दूध पी रही है।', exampleEnglish: 'The cat is drinking milk.' },
    { hindi: 'गाय', english: 'Cow', transliteration: 'Gaay', exampleHindi: 'गाय दूध देती है।', exampleEnglish: 'The cow gives milk.' },
    { hindi: 'हाथी', english: 'Elephant', transliteration: 'Haathi', exampleHindi: 'हाथी जंगल में रहता है।', exampleEnglish: 'The elephant lives in the jungle.' },
    { hindi: 'शेर', english: 'Lion', transliteration: 'Sher', exampleHindi: 'शेर जंगल का राजा है।', exampleEnglish: 'The lion is the king of the jungle.' },
    { hindi: 'पक्षी', english: 'Bird', transliteration: 'Pakshi', exampleHindi: 'पक्षी आकाश में उड़ते हैं।', exampleEnglish: 'Birds fly in the sky.' },
    { hindi: 'मछली', english: 'Fish', transliteration: 'Machli', exampleHindi: 'मछली पानी में तैरती है।', exampleEnglish: 'Fish swim in water.' },
    { hindi: 'घोड़ा', english: 'Horse', transliteration: 'Ghoda', exampleHindi: 'घोड़ा तेज़ दौड़ता है।', exampleEnglish: 'The horse runs fast.' },
  ],
};

const seedDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI ||
      'mongodb://localhost:27017/hindi_learning_app');
    console.log('✅ MongoDB connected for seeding');

    // Clear existing data
    await Lesson.deleteMany({});
    await Word.deleteMany({});
    console.log('🗑️  Cleared existing lessons and words');

    // Insert lessons
    const insertedLessons = await Lesson.insertMany(lessons);
    console.log(`✅ Inserted ${insertedLessons.length} lessons`);

    // Insert words for each lesson
    let totalWords = 0;
    for (const lesson of insertedLessons) {
      const words = wordsByLesson[lesson.title];
      if (words) {
        const wordsWithLesson = words.map((w) => ({
          ...w,
          lessonId: lesson._id,
          difficulty: lesson.unitNumber === 1 ? 'easy' : 'medium',
        }));
        await Word.insertMany(wordsWithLesson);
        totalWords += words.length;
        console.log(`  ✅ ${words.length} words → "${lesson.title}"`);
      }
    }

    console.log(`\n🎉 Seeding complete!`);
    console.log(`   📚 ${insertedLessons.length} lessons`);
    console.log(`   🔤 ${totalWords} words`);
    process.exit(0);
  } catch (err) {
    console.error('❌ Seeding failed:', err);
    process.exit(1);
  }
};

seedDB();