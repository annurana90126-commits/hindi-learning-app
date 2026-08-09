const User = require('../models/User');
const { generateToken } = require('../utils/jwt');

// ─── REGISTER ────────────────────────────────────────────────────────────────
const register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;

    // Validate input
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide name, email and password.',
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'An account with this email already exists.',
      });
    }

    // Create user
    const user = await User.create({
      name,
      email,
      password,
    });

    // Generate JWT
    const token = generateToken(user._id);

    return res.status(201).json({
      success: true,
      message: 'Account created successfully!',
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        xp: user.xp,
        level: user.level,
        streak: user.streak,
        wordsLearned: user.wordsLearned,
        lessonsCompleted: user.lessonsCompleted,
        dailyGoalXp: user.dailyGoalXp,
      },
    });
  } catch (error) {
    console.log('\n========== REGISTER ERROR ==========');
    console.error(error);
    console.error(error.stack);
    console.log('====================================\n');

    next(error);
  }
};

// ─── LOGIN ────────────────────────────────────────────────────────────────────
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password.',
      });
    }

    const user = await User.findOne({ email }).select('+password');

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password.',
      });
    }

    const isMatch = await user.comparePassword(password);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password.',
      });
    }

    await updateStreak(user);

    const token = generateToken(user._id);

    return res.status(200).json({
      success: true,
      message: 'Login successful!',
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        xp: user.xp,
        level: user.level,
        streak: user.streak,
        wordsLearned: user.wordsLearned,
        lessonsCompleted: user.lessonsCompleted,
        dailyGoalXp: user.dailyGoalXp,
      },
    });
  } catch (error) {
    console.log('\n========== LOGIN ERROR ==========');
    console.error(error);
    console.error(error.stack);
    console.log('=================================\n');

    next(error);
  }
};

// ─── GET PROFILE ──────────────────────────────────────────────────────────────
const getProfile = async (req, res) => {
  const user = await User.findById(req.user._id);

  return res.status(200).json({
    success: true,
    user: {
      id: user._id,
      name: user.name,
      email: user.email,
      xp: user.xp,
      level: user.level,
      streak: user.streak,
      wordsLearned: user.wordsLearned,
      lessonsCompleted: user.lessonsCompleted,
      dailyGoalXp: user.dailyGoalXp,
    },
  });
};

// ─── UPDATE STREAK ────────────────────────────────────────────────────────────
const updateStreak = async (user) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const lastActive = user.lastActiveDate
    ? new Date(user.lastActiveDate)
    : null;

  if (lastActive) {
    lastActive.setHours(0, 0, 0, 0);

    const diffDays = Math.floor(
      (today - lastActive) / (1000 * 60 * 60 * 24)
    );

    if (diffDays === 0) {
      return;
    } else if (diffDays === 1) {
      user.streak += 1;
    } else {
      user.streak = 1;
    }
  } else {
    user.streak = 1;
  }

  user.lastActiveDate = new Date();
  await user.save();
};

module.exports = {
  register,
  login,
  getProfile,
};