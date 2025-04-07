const express = require("express");
const router = express.Router();
const Step = require("../models/Step");
const auth = require("../middleware/auth");

// Middleware to verify JWT token
router.use(auth);

// Get steps for a specific date range
router.get("/weekly", async (req, res) => {
  try {
    const userId = req.user.userId;
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 7); // Last 7 days

    const steps = await Step.find({
      userId,
      date: {
        $gte: startDate,
        $lte: endDate,
      },
    }).sort({ date: 1 });

    res.json(steps);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

// Record daily steps
router.post("/daily", async (req, res) => {
  try {
    const userId = req.user.userId;
    const { steps } = req.body;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Update or create steps record for today
    const stepRecord = await Step.findOneAndUpdate(
      { userId, date: today },
      { steps },
      { upsert: true, new: true }
    );

    res.json(stepRecord);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

module.exports = router;
