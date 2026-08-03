<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\LegalCase>
 */
class LegalCaseFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'title' => fake()->randomElement([
                'Title Suit for Partition',
                'Criminal Trespass Case',
                'Money Loan Recovery Suit',
                'Specific Performance of Contract',
                'Divorce and Maintenance Petition',
                'Writ Petition (Certiorari)',
                'Cheque Dishonour Case',
                'Land Boundary Dispute',
                'Tortious Claim for Damages',
                'Family Custody Petition',
            ]),
            'case_number' => fake()->randomElement([
                'Civil Suit No. 145 of 2024',
                'C.R. Case No. 823 of 2024',
                'Money Suit No. 66 of 2023',
                'W.P. No. 5412 of 2024',
                'Title Appeal No. 210 of 2023',
                'Criminal Appeal No. 98 of 2024',
                'Execution Case No. 332 of 2024',
                'Arbitration Case No. 17 of 2025',
            ]),
            'client_name' => fake()->randomElement([
                'Md. Abdul Karim',
                'Fatema Begum',
                'Rafiqul Islam',
                'Nusrat Jahan',
                'Shahidul Alam',
                'Ayesha Siddiqua',
                'Mizanur Rahman',
                'Tahmina Akter',
                'Kamal Hossain',
                'Shirin Sultana',
            ]),
            'client_phone' => '01' . fake()->numberBetween(3, 9) . fake()->numerify('########'),
            'court_name' => fake()->randomElement([
                'Dhaka District Judge Court',
                'Chief Metropolitan Magistrate Court, Dhaka',
                'Civil Judge Court, Chattogram',
                'Family Court, Dhaka',
                'High Court Division, Dhaka',
                'District Court, Rajshahi',
                'Metropolitan Sessions Court, Dhaka',
                'Joint District Judge Court, Khulna',
            ]),
            'opposing_party' => fake()->randomElement([
                'Md. Golam Mostofa',
                'Mrs. Roksana Parvin',
                'Bangladesh Bank',
                'City Corporation, Dhaka',
                'Md. Jahangir Alam',
                'Rupali Bank Limited',
                'Md. Selim Chowdhury',
                'National Housing Authority',
            ]),
            'case_type' => fake()->randomElement([
                'Civil',
                'Criminal',
                'Family',
                'Labour',
                'Revenue',
                'Constitutional',
                'Arbitration',
                'Banking',
            ]),
'status' => fake()->randomElement(['active', 'active', 'active', 'on_hold', 'closed']),
            'notes' => fake()->optional()->sentence(10),
            'client_email' => fake()->optional()->safeEmail(),
            'client_address' => fake()->optional()->address(),
            'judge_name' => fake()->optional()->randomElement([
                'Md. Kamal Hossain', 'Salma Khatun', 'A.K.M. Shafiul Alam', 'Farhana Yasmin',
            ]),
            'bench' => fake()->optional()->randomElement([
                'Civil Bench 1', 'Criminal Bench 2', 'Family Bench 3', 'Special Bench',
            ]),
            'filing_date' => fake()->optional()->dateTimeBetween('-2 years', 'now')->format('Y-m-d'),
            'next_hearing_date' => fake()->optional(0.6)->dateTimeBetween('now', '+1 month')->format('Y-m-d'),
            'judgment_date' => null,
            'reminder_date' => fake()->optional(0.4)->dateTimeBetween('now', '+3 weeks')->format('Y-m-d'),
            'reminder_time' => fake()->optional(0.4)->time('H:i'),
            'reminder_option' => fake()->optional()->randomElement(['1', '2', '3', '7', 'custom']),
            'repeat_reminder' => fake()->boolean(30),
            'opposing_lawyer' => fake()->optional()->randomElement([
                'Advocate Rahim Mia', 'Barrister Nusrat Jahan', 'Advocate Selim Chowdhury',
            ]),
            'professional_fee' => fake()->optional()->randomElement([5000, 10000, 15000, 25000, 50000]),
            'paid_amount' => fake()->optional()->randomElement([0, 5000, 10000, 20000]),
            'due_amount' => fake()->optional()->randomElement([0, 5000, 10000, 15000]),
            'payment_status' => fake()->randomElement(['unpaid', 'partial', 'paid']),
            'case_progress' => [
                ['stage' => 'created', 'timestamp' => now()->subDays(rand(1, 30))->toIso8601String()],
            ],
            'ai_flags' => [],
        ];
    }

    /**
     * Keep only active cases.
     */
    public function active(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'active',
        ]);
    }
}

