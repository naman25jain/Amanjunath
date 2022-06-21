@IsTest
public class ContactMedicalSchoolViewModelTest{
    @IsTest
    public static void testContactMedicalSchoolViewModel(){
        ContactMedicalSchoolViewModel varDeclaration = new ContactMedicalSchoolViewModel();
        varDeclaration.SchoolName = 'Global Research Institute';
        system.assert(varDeclaration.SchoolName != null, 'SchoolName is Null');
        varDeclaration.Address1 = 'White House';
        varDeclaration.Address2 = '1600 Pennsylvania Ave NW';
        system.assert(varDeclaration.Address2 != null, 'Adddress second line is Null');
        varDeclaration.Address3 = 'Washington DC';
        varDeclaration.Address4 = 'Zip 20500';
        varDeclaration.DegreeTitle = 'Bachelor of Medicine';
        system.assert(varDeclaration.DegreeTitle != null, 'Degree Title is Null');
        varDeclaration.StudentId = '00147';
        varDeclaration.StartDate = Date.newInstance(2015, 6, 2);
        varDeclaration.StartYear = '2015';
        varDeclaration.StartMonth = 'June';
        varDeclaration.EndYear = '2020';
        varDeclaration.EndMonth = 'April';
        varDeclaration.EndDate = Date.newInstance(2020, 4, 23);
        varDeclaration.DegreeDate = Date.newInstance(2021, 2, 1);
    }
}