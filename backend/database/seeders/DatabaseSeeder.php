<?php

namespace Database\Seeders;

use App\Models\Deadline;
use App\Models\LegalCase;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // ─── Super Admin ──────────────────────────────────────────────
        User::factory()->admin()->create([
            'name' => 'Adalot Sathi Admin',
            'email' => 'admin@adalotsathi.com',
            'phone' => '01700000001',
            'password' => 'Admin@1234',
        ]);

        // ─── Demo Free-Tier Lawyer (5 active cases → limit reached) ───
$freeUser = User::factory()->create([
            'name' => 'Barrister Tanvir Ahmed',
            'email' => 'tanvir@example.com',
            'phone' => '01712345678',
            'password' => 'Password@123',
            'subscription_tier' => 'free',
            'bar_council_number' => 'BC-2023-0471',
            'chamber_name' => 'Tanvir & Associates, Dhaka',
            'address' => 'House 12, Road 5, Dhanmondi, Dhaka',
            'district' => 'Dhaka',
            'years_of_experience' => 12,
            'practice_areas' => ['Criminal', 'Civil', 'Family'],
            'preferred_court' => 'Dhaka District Court',
            'app_language' => 'bn',
        ]);

        foreach ([
            [
                'title' => 'Money Recovery Suit against Rupali Bank',
                'case_number' => 'Money Suit No. 66 of 2023',
                'client_name' => 'Md. Abdul Karim',
                'court_name' => 'Dhaka District Judge Court',
                'opposing_party' => 'Rupali Bank Limited',
                'case_type' => 'Banking',
            ],
            [
                'title' => 'Title Suit for Partition of Ancestral Land',
                'case_number' => 'Title Suit No. 145 of 2024',
                'client_name' => 'Fatema Begum',
                'court_name' => 'Civil Judge Court, Chattogram',
                'opposing_party' => 'Md. Golam Mostofa',
                'case_type' => 'Civil',
            ],
            [
                'title' => 'Cheque Dishonour Case under N.I. Act',
                'case_number' => 'C.R. Case No. 823 of 2024',
                'client_name' => 'Shahidul Alam',
                'court_name' => 'Chief Metropolitan Magistrate Court, Dhaka',
                'opposing_party' => 'Md. Jahangir Alam',
                'case_type' => 'Criminal',
            ],
            [
                'title' => 'Specific Performance of Sale Agreement',
                'case_number' => 'Title Suit No. 289 of 2024',
                'client_name' => 'Nusrat Jahan',
                'court_name' => 'District Court, Rajshahi',
                'opposing_party' => 'Mrs. Roksana Parvin',
                'case_type' => 'Civil',
            ],
            [
                'title' => 'Custody Petition under Family Law',
                'case_number' => 'Family Suit No. 77 of 2024',
                'client_name' => 'Tahmina Akter',
                'court_name' => 'Family Court, Dhaka',
                'opposing_party' => 'Md. Selim Chowdhury',
                'case_type' => 'Family',
            ],
        ] as $caseData) {
            $legalCase = $freeUser->legalCases()->create($caseData);

            $this->createDeadlines($legalCase);
        }

        // ─── Paid-Tier Lawyer (unlimited cases) ───────────────────────
$paidUser = User::factory()->paid()->create([
            'name' => 'Advocate Sadia Rahman',
            'email' => 'sadia@example.com',
            'phone' => '01812345678',
            'password' => 'Password@123',
            'bar_council_number' => 'BC-2022-1189',
            'chamber_name' => 'Sadia Rahman & Co.',
            'address' => 'Flat 3B, Green Road, Dhaka',
            'district' => 'Dhaka',
            'years_of_experience' => 8,
            'practice_areas' => ['Corporate', 'Property', 'Tax'],
            'preferred_court' => 'High Court Division',
            'app_language' => 'bn',
        ]);

        foreach ([
            [
                'title' => 'Writ Petition against NHA',
                'case_number' => 'W.P. No. 5412 of 2024',
                'client_name' => 'Mizanur Rahman',
                'court_name' => 'High Court Division, Dhaka',
                'opposing_party' => 'National Housing Authority',
                'case_type' => 'Constitutional',
            ],
            [
                'title' => 'Criminal Appeal against Conviction',
                'case_number' => 'Criminal Appeal No. 98 of 2024',
                'client_name' => 'Kamal Hossain',
                'court_name' => 'Metropolitan Sessions Court, Dhaka',
                'opposing_party' => 'State',
                'case_type' => 'Criminal',
            ],
            [
                'title' => 'Arbitration Proceeding for Commercial Dispute',
                'case_number' => 'Arbitration Case No. 17 of 2025',
                'client_name' => 'Shirin Sultana',
                'court_name' => 'Dhaka District Judge Court',
                'opposing_party' => 'Bangladesh Bank',
                'case_type' => 'Arbitration',
            ],
            [
                'title' => 'Divorce and Maintenance Petition',
                'case_number' => 'Family Suit No. 122 of 2024',
                'client_name' => 'Ayesha Siddiqua',
                'court_name' => 'Family Court, Dhaka',
                'opposing_party' => 'Rafiqul Islam',
                'case_type' => 'Family',
            ],
        ] as $caseData) {
            $legalCase = $paidUser->legalCases()->create($caseData);

            $this->createDeadlines($legalCase);
        }

        // ─── Extra random lawyers (mix of free/paid) for realism ──────
        User::factory()->count(5)->create()->each(function ($user) {
            $statusPool = ['active', 'active', 'active', 'on_hold', 'closed'];
            $caseCount = $user->subscription_tier === 'paid' ? rand(6, 10) : rand(1, 5);

            LegalCase::factory()
                ->count($caseCount)
                ->state(function () use ($statusPool) {
                    return ['status' => $statusPool[array_rand($statusPool)]];
                })
                ->create(['user_id' => $user->id])
                ->each(function (LegalCase $legalCase) {
                    $this->createDeadlines($legalCase);
                });
        });
    }

    /**
     * Create a handful of realistic deadlines for a case.
     */
    private function createDeadlines(LegalCase $legalCase): void
    {
        $templates = [
            ['title' => 'Hearing for ad-interim injunction', 'event_type' => 'hearing', 'days' => 2, 'time' => '10:00'],
            ['title' => 'Filing of written statement', 'event_type' => 'filing', 'days' => 5, 'time' => '11:00'],
            ['title' => 'Appeal submission deadline', 'event_type' => 'appeal', 'days' => 9, 'time' => '14:00'],
            ['title' => 'Witness examination', 'event_type' => 'hearing', 'days' => 14, 'time' => '10:30'],
            ['title' => 'Compliance hearing', 'event_type' => 'hearing', 'days' => 21, 'time' => null],
            ['title' => 'Deposit of decretal amount', 'event_type' => 'filing', 'days' => 30, 'time' => '12:00'],
            ['title' => 'Submission of expert report', 'event_type' => 'other', 'days' => 45, 'time' => null],
        ];

        // Use a rotating subset so every case has 2-4 deadlines.
        $offset = rand(0, count($templates) - 1);
        $selected = [];
        for ($i = 0; $i < rand(2, 4); $i++) {
            $selected[] = $templates[($offset + $i) % count($templates)];
        }

        foreach ($selected as $template) {
            Deadline::factory()->create([
                'case_id' => $legalCase->id,
                'title' => $template['title'],
                'event_type' => $template['event_type'],
                'due_date' => now()->addDays($template['days'])->toDateString(),
                'due_time' => $template['time'],
                'status' => 'pending',
                'reminder_days_before' => [7, 3, 1],
            ]);
        }

        // Occasionally add an overdue deadline.
        if (rand(0, 1) === 0) {
            Deadline::factory()->create([
                'case_id' => $legalCase->id,
                'title' => 'Missed hearing for submission of documents',
                'event_type' => 'hearing',
                'due_date' => now()->subDays(rand(1, 3))->toDateString(),
                'due_time' => '10:00',
                'status' => 'pending',
                'reminder_days_before' => [7, 3, 1],
            ]);
        }
    }
}

