const mongoose = require("mongoose");

const stepSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  date: {
    type: Date,
    required: true,
    default: Date.now,
  },
  steps: {
    type: Number,
    required: true,
    default: 0,
  },
});

// Create compound index for efficient querying
stepSchema.index({ userId: 1, date: 1 }, { unique: true });

module.exports = mongoose.model("Step", stepSchema);
